/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

/* 
 * ASILUC - An ASIC designed to function as an ALU.
 *
 * Pinout description:
 * ui_in[7:0] - The input for the numbers to be processed by the ALU.
 * uo_out[7:0] - The output for the result of the ALU (16 bits, split into two 8-bit outputs).
 * uio_in[3:0] - The input for the command to be processed by the ALU.
 * uio_out[7:4] - The output for the status of the ALU (4 bits - busy | status | highByte | error).
 * uio_oe[7:0] - The output enable for the io pins. Fixed at 8'b11110000.
 * ena - Always high when the design is powered, can be ignored.
 * clk - The clock signal for the design.
 * rst_n - The reset signal for the design, active low.
 */

`default_nettype none

module tt_um_gianluca_rainis_ASILUC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b11110000;  // [7:4] are outputs (status), [3:0] are inputs (commands)

  reg [3:0] command_in; // The command received from the uio_in[3:0] inputs
  reg [7:0] first_number_in;  // First number for the operation
  reg [7:0] second_number_in; // Second number for the operation
  reg [15:0] number_out;  // The result of the operation (16 bits)

  reg previous_command_NOP = 1'b0;  // Flag to indicate if the previous command was NOP
  reg [3:0] asiluc_status = 4'b0000;  // Status register for ASILUC
  reg error_reg = 1'b0; // Error register for ASILUC
  reg done_calculation = 1'b0;  // Done signal for the calculation module

  wire last_cycle;  // Signal to indicate the last cycle of the clock counter has been reached
  wire run_phase_timer;  // If run the clock phase_timer

  reg handle_command_input = 1'b1;  // Flag to indicate if handling command input
  reg handle_number_input = 1'b0; // Flag to indicate if handling number input

  phase_timer_ASILUC phase_timer (
    .run(run_phase_timer),
    .clk(clk),
    .rst_n(rst_n),
    .last_cycle(last_cycle)
  );

  calculation_ASILUC calculation (
    .number1(first_number_in),
    .number2(second_number_in),
    .command(command_in),
    .result(number_out),
    .error(error_reg),
    .start(asiluc_status == 4'b1000),  // Start calculation when
    .done(done_calculation) // Done when calculation is complete
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin // Reset
      previous_command_NOP <= 1'b0; // Reset NOP flag on reset

      command_in <= 4'b0000;  // Reset command on reset
      first_number_in <= 8'b00000000; // Reset first number on reset
      second_number_in <= 8'b00000000;  // Reset second number on reset
      number_out <= 16'b0000000000000000; // Reset result on reset

      asiluc_status <= 4'b0000; // Reset status on reset
      handle_command_input <= 1'b1; // Reset command input flag on reset
      handle_number_input <= 1'b0;  // Reset number input flag on reset
    end
    else begin  // Normal operation
      if (handle_command_input) begin // Handle command input
        command_in <= uio_in[3:0];  // Save command

        if (command_in == 4'b0000) begin
          previous_command_NOP <= 1'b1; // NOP, set flag
        end
        else if (command_in >= 4'b0101 && command_in <= 4'b1111) begin  // Invalid command range
          previous_command_NOP <= 1'b0; // Reset flag if command is not NOP
          handle_number_input <= 1'b0;  // Reset number input flag
        end
        else if (previous_command_NOP) begin
          if (last_cycle) begin
            asiluc_status <= 4'b0100; // Command accepted | Input (first number) expected

            // Handle numbers input
            handle_number_input <= 1'b1;
            handle_command_input <= 1'b0; // Stop handling command input
            
            previous_command_NOP <= 1'b0; // Reset flag
          end
        end
        else begin
          previous_command_NOP <= 1'b0; // Reset flag if command is not NOP
          handle_number_input <= 1'b0;  // Reset number input flag
        end
      end
      else if (handle_number_input) begin // Handle number input
        if (last_cycle && asiluc_status == 4'b0100) begin
          first_number_in <= ui_in; // Save first number
          asiluc_status <= 4'b0110; // Input (second number) expected
        end
        else if (last_cycle && asiluc_status == 4'b0110) begin
          second_number_in <= ui_in; // Save second number
          asiluc_status <= 4'b1000; // Calculating

          handle_number_input <= 1'b0; // Stop handling number input
        end
      end
      else if (asiluc_status == 4'b1000) begin  // Handle calculation
        // Handle calculation
      end
      else begin  // Invalid state, reset
        asiluc_status <= 4'b0001; // Error: Invalid state, reset to idle
        number_out <= 16'b0000000000000000; // Reset result
        number_out[3:0] <= 4'b0000; // Set error code to Generic Error

        if (last_cycle) begin
          previous_command_NOP <= 1'b0; // Reset NOP flag on reset

          command_in <= 4'b0000;  // Reset command on reset
          first_number_in <= 8'b00000000; // Reset first number on reset
          second_number_in <= 8'b00000000;  // Reset second number on reset
          number_out <= 16'b0000000000000000; // Reset result on reset

          asiluc_status <= 4'b0000; // Reset status on reset
          handle_command_input <= 1'b1; // Reset command input flag on reset
          handle_number_input <= 1'b0;  // Reset number input flag on reset
        end
      end
    end
  end

  assign run_phase_timer = (handle_command_input && previous_command_NOP && (command_in > 4'b0000 && command_in < 4'b0101)) || handle_number_input || (asiluc_status == 4'b0001); // Run the phase timer when handling command or number input

  assign uio_out = {asiluc_status, 4'b0000}; // ASILUC status on uio_out[7:4] and zeros on uio_out[3:0]
  assign uo_out = (asiluc_status == 4'b1100) ? number_out[7:0] : ((asiluc_status == 4'b1110) ? number_out[15:8] : 8'b0);  // Output the lower 8 bits of the result or the upper 8 bits of the result or zero

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:4], 1'b0};

endmodule
