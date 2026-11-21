/*
 * Copyright (c) 2026 Gianluca Rainis
 * SPDX-License-Identifier: Apache-2.0
 */

module main_icepi_zero (
    input wire clk,
    output logic [4:0] led
);
    // The machine states
    localparam RESET = 3'b000;
    localparam SEND_CMD = 3'b001;
    localparam WAIT_FIRST = 3'b010;
    localparam WAIT_SECOND = 3'b011;
    localparam CALCULATING = 3'b100;
    localparam WAIT_RESULT_LOW = 3'b101;
    localparam WAIT_RESULT_HIGH = 3'b110;
    localparam DONE = 3'b111;

    reg [2:0] state = RESET;
    reg [31:0] pause_counter = 0;
    
    // tt_um_gianluca_rainis_ASILUC I/O
    reg [7:0] ui_in = 0;
    wire [7:0] uo_out;
    reg [7:0] uio_in = 0;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    wire ena = 1'b1;
    reg rst_n = 0;

    reg [7:0] result_low = 0;
    reg [7:0] result_high = 0;
    wire [3:0] status = uio_out[7:4]; // ASILUC's status

    tt_um_gianluca_rainis_ASILUC asiluc (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Reset the leds
    initial begin
        led = 5'b00000;
    end

    always @(posedge clk) begin
        case (state)
            RESET: begin
                if (pause_counter == 8'b10100) begin
                    rst_n <= 1'b1;
                    pause_counter <= 0;
                    state <= SEND_CMD;
                end
                else begin
                    pause_counter <= pause_counter + 1'b1;
                end
            end
            SEND_CMD: begin
                if (pause_counter == 8'b00001010) begin
                    uio_in <= 8'b00000001; // SUM
                    pause_counter <= 0;
                    state <= WAIT_FIRST;
                end
                else begin
                    pause_counter <= pause_counter + 1'b1;
                end
            end
            WAIT_FIRST: begin
                if (status == 4'b0100) begin
                    ui_in <= 8'b00001010; // Set first number
                    state <= WAIT_SECOND;
                end
            end
            WAIT_SECOND: begin
                if (status == 4'b0110) begin
                    ui_in <= 8'b00010100; // Set second number
                    state <= CALCULATING;
                end
            end
            CALCULATING: begin
                if (status == 4'b1000) begin
                    state <= WAIT_RESULT_LOW; // ASILUC is calculating
                end
            end
            WAIT_RESULT_LOW: begin
                if (status == 4'b1100) begin
                    result_low <= uo_out;
                    state <= WAIT_RESULT_HIGH;
                end
            end
            WAIT_RESULT_HIGH: begin
                if (status == 4'b1110) begin
                    result_high <= uo_out;
                    state <= DONE;
                end
            end
            DONE: begin
                if (pause_counter == 32'd25000000) begin
                    led <= {1'b1, result_low[3:0]};
                    pause_counter <= pause_counter + 1'b1;
                end
                else if (pause_counter == 32'd50000000) begin
                    led <= {1'b1, result_low[7:4]};
                    pause_counter <= pause_counter + 1'b1;
                end
                else if (pause_counter == 32'd75000000) begin
                    led <= {1'b1, result_high[3:0]};
                    pause_counter <= pause_counter + 1'b1;
                end
                else if (pause_counter == 32'd100000000) begin
                    led <= {1'b1, result_high[7:4]};
                    pause_counter <= pause_counter + 1'b1;
                end
                else if (pause_counter == 32'd125000000) begin
                    pause_counter <= 0;
                end
                else begin
                    pause_counter <= pause_counter + 1'b1;
                end
            end
            default: begin
                state <= RESET;
                rst_n <= 1'b0;
                pause_counter <= 0;
                ui_in <= 0;
                uio_in <= 0;
                led <= 0;
            end
        endcase
    end
endmodule
