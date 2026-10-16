/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module phase_timer_ASILUC (
    input   wire    run,    // If high, the timer will count clock cycles
    input   wire    clk,    // clock
    input   wire    rst_n,  // reset_n - low to reset
    output  wire    last_cycle  // High if the last cycle has been reached
);

  reg [1:0] clock_counter;  // Counter to track clock cycles

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clock_counter <= 2'b00; // Reset counter on reset
    end
    else begin
      if (run) begin
        if (clock_counter == 2'b10) begin
          clock_counter <= 2'b00;   // Reset counter
        end
        else begin
          clock_counter <= clock_counter + 1'b1;    // Increment counter
        end
      end
      else begin
        clock_counter <= 2'b00; // Reset counter when not running
      end
    end
  end

  assign last_cycle = run & (clock_counter == 2'b10);   // Assign the last cycle signal to the output

endmodule
