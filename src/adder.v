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
    assign sum = a ^ b ^ cin;               // Sum output
    assign cout = (a & b) | ((a ^ b) & cin);  // Carry output
endmodule
