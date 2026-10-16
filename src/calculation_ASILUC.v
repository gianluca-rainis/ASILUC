/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module calculation_ASILUC (
    input   wire [7:0]  number1,    // First number for the operation
    input   wire [7:0]  number2,    // Second number for the operation
    input   wire [3:0]  command,    // Command for the operation
    output  wire [15:0] result,     // The result of the operation (16 bits)
    input   wire        clk,        // clock
    input   wire        rst_n,      // reset_n - low to reset
    output  wire        error,      // 1 if there is an error, 0 otherwise
    input   wire        start,      // Signal to indicate the start of the operation
    output  wire        done        // Signal to indicate the completion of the operation
);

    reg [15:0] result_reg;  // The result of the operation (16 bits)
    reg done_reg;           // Signal to indicate the completion of the operation
    reg error_reg;          // Signal to indicate an error in the operation

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_reg <= 16'b0000000000000000; // Reset result to zero
            done_reg <= 1'b0;                   // Reset done signal
            error_reg <= 1'b0;  // Default no error
        end
        else begin
            error_reg <= 1'b0;  // Default no error

            if (start) begin
                case (command)
                    4'b0000: result_reg <= 16'b0000000000000000;    // NOP
                    4'b0001: result_reg <= { 8'b00000000, number1 } + { 8'b00000000, number2 };  // Addition
                    4'b0010: result_reg <= { 8'b00000000, number1 } - { 8'b00000000, number2 };  // Subtraction
                    4'b0011: result_reg <= number1 * number2;       // Multiplication
                    4'b0100: begin
                        if (number2 != 0) begin
                            result_reg <= { 8'b00000000, number1 / number2 };   // Division
                        end
                        else begin
                            error_reg <= 1'b1;                  // Error: Division by zero
                            result_reg <= 16'b0000000000000001; // Error: Division by zero
                        end
                    end
                    default: result_reg <= 16'b0000000000000000;    // Default case, return zero
                endcase

                done_reg <= 1'b1;   // Calculation done
            end
            else begin
                done_reg <= 1'b0;                   // Not done when not started
            end
        end
    end

    assign result = result_reg;
    assign error = error_reg;
    assign done = done_reg;
endmodule
