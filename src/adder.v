/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module adder (
    input   wire    a,      // First input
    input   wire    b,      // Second input
    input   wire    cin,    // Carry input
    output  wire    sum,    // Sum output
    output  wire    cout,   // Carry output
);
    assign {cout, sum} = a + b + cin;   // Perform addition of a, b, and cin, and assign the result to cout and sum
endmodule
