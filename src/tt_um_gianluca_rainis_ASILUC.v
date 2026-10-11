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
  reg [1:0] clock_counter = 2'b00;  // Counter to track clock cycles

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      previous_command_NOP <= 1'b0; // Reset NOP flag on reset
      clock_counter <= 2'b00; // Reset counter on reset

      command_in <= 4'b0000;  // Reset command on reset
      first_number_in <= 8'b00000000; // Reset first number on reset
      second_number_in <= 8'b00000000;  // Reset second number on reset
      number_out <= 16'b0000000000000000; // Reset result on reset

      asiluc_status <= 4'b0000; // Reset status on reset
    end
    else begin
      if (clock_counter == 2'b10) begin
        clock_counter <= 2'b00; // Reset counter
      end
      else begin
        clock_counter <= clock_counter + 1'b1;  // Increment counter
      end
      
      command_in <= uio_in[3:0];

      if (command_in == 4'b0000) begin
        previous_command_NOP <= 1'b1; // NOP, set flag
      end
      else if (previous_command_NOP) begin
        clock_counter <= 2'b11;

        if (clock_counter == 2'b00) begin
          command_in <= uio_in[3:0]; // Save command
          asiluc_status <= 4'b0100; // Command accepted

          // Handle numbers input

          previous_command_NOP <= 1'b0; // Reset flag
        end

        clock_counter <= 2'b00;
      end
      else begin
        previous_command_NOP <= 1'b0; // Reset flag if command is not NOP
      end
    end
  end

  assign uio_out[7:0] = {asiluc_status, 4'b0000}; // ASILUC status on uio_out[7:4] and zeros on uio_out[3:0]

  if (asiluc_status == 4'b1100) begin
    assign uo_out[7:0] = number_out[7:0]; // Output the lower 8 bits of the result
  end
  else if (asiluc_status == 4'b1110) begin
    assign uo_out[7:0] = number_out[15:8];  // Output the upper 8 bits of the result
  end
  else begin
    assign uo_out[7:0] = 8'b00000000; // Default output when not in result state
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:4], 1'b0};

endmodule
