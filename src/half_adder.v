/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module half_adder (
    input   wire    a,      // First input
    input   wire    b,      // Second input
    output  wire    sum,    // Sum output
    output  wire    cout,   // Carry output
);
    assign sum = a ^ b;     // Sum output
    assign cout = a & b;    // Carry output
endmodule
