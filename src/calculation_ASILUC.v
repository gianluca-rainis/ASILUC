/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module calculation_ASILUC (
    input  wire [7:0]   number1,    // First number for the operation
    input  wire [7:0]   number2,    // Second number for the operation
    input  wire [3:0]   command,    // Command for the operation
    output wire [15:0]  result,     // The result of the operation (16 bits)
    output wire [3:0]   status      // The status of the operation (4 bits)
);

    reg [15:0] result_reg;   // The result of the operation (16 bits)
    reg [3:0] status_reg;    // The status of the operation (4 bits)

    always @(*) begin
        status_reg = 4'b1000;   // Default status: Calculation

        case (command)
            4'b0000: result_reg = 16'b0000000000000000;  // NOP
            4'b0001: result_reg = number1 + number2;     // Addition
            4'b0010: result_reg = number1 - number2;     // Subtraction
            4'b0011: result_reg = number1 * number2;     // Multiplication
            4'b0100: begin
                if (number2 != 0) begin
                    result_reg = number1 / number2;      // Division
                end
                else begin
                    status_reg = 4'b0001;                // Status: Error
                    result_reg = 16'b0000000000000001;   // Error: Division by zero
                end
            end
            default: result_reg = 16'b0000000000000000;  // Default case, return zero
        endcase
    end

    assign result = result_reg;
    assign status = status_reg;
endmodule
