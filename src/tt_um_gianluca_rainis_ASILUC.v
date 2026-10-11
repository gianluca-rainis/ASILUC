/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
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
  assign uo_out = 0;
  assign uio_out = 0;           // busy | status | highByte | error

  wire [3:0] uio_in_command = uio_in[3:0];  // [3:0] are commands
  reg previous_command_NOP = 1'b0;   // Flag to indicate if the previous command was NOP

  always @(posedge clk) begin
    if (uio_in_command == 4'b0000) begin
      previous_command_NOP <= 1'b1;   // NOP, set flag
    end
    else begin
      if (previous_command_NOP) begin // Previous command was NOP, handle the current command
        case (uio_in_command)
          4'b0001: begin
            // Command SUM
          end
          4'b0010: begin
            // Command SUB
          end
          4'b0011: begin
            // Command MUL
          end
          4'b0100: begin
            // Command DIV
          end
          default: begin
            // Unknown command, NOP
          end
        endcase
      end

      previous_command_NOP <= 1'b0; // Reset flag for other commands
    end
  end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
