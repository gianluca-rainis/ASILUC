
`default_nettype none
`timescale 1ns / 1ps

module tb;

  reg clk = 1'b0;
  reg rst_n = 1'b0;

  // Inputs
  reg [7:0] number1 = 8'b0;
  reg [7:0] number2 = 8'b0;
  reg [3:0] command = 4'b0;
  reg start = 1'b0;

  // Outputs
  wire [15:0] result;
  wire error;
  wire done;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Device Under Test
  calculation_ASILUC user_project (
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .number1(number1),
    .number2(number2),
    .command(command),
    .result(result),
    .clk(clk),
    .rst_n(rst_n),
    .error(error),
    .start(start),
    .done(done)
  );

  // Clock: 10 ns period
  always #5 clk = ~clk;

  integer passed = 0;
  integer failed = 0;

  // Execute one transaction and check the expected outputs
  task run_test;
    input [8*40-1:0] test_name;
    input [7:0] a;
    input [7:0] b;
    input [3:0] cmd;
    input [15:0] expected_result;
    input expected_error;

    integer cycles;

    begin
      // Wait for a clean starting point
      @(negedge clk);
      number1 = a;
      number2 = b;
      command = cmd;
      start = 1'b1;

      // Start asserted for one clock interval
      @(negedge clk);
      start = 1'b0;

      // Wait for completion
      cycles = 0;
      while (done !== 1'b1 && cycles < 100) begin
        @(posedge clk);
        cycles = cycles + 1;
      end

      // Allow nonblocking assignments to settle
      #1;

      if (done !== 1'b1) begin
        $display("FAIL: %0s - timeout", test_name);
        failed = failed + 1;
      end else if (
        result !== expected_result ||
        error !== expected_error
      ) begin
        $display(
          "FAIL: %0s | A=%0d B=%0d CMD=%04b | result=%0d expected=%0d | error=%b expected=%b",
          test_name, a, b, cmd, result, expected_result,
          error, expected_error
        );
        failed = failed + 1;
      end else begin
        $display(
          "PASS: %0s | A=%0d B=%0d CMD=%04b | result=%0d error=%b",
          test_name, a, b, cmd, result, error
        );
        passed = passed + 1;
      end

      // Wait for done to deassert before next transaction
      cycles = 0;
      while (done !== 1'b0 && cycles < 100) begin
        @(negedge clk);
        cycles = cycles + 1;
      end

      if (done !== 1'b0) begin
        $display(
          "WARNING: done did not return low after %0s",
          test_name
        );
      end
    end
  endtask

  initial begin
    $dumpfile("tb_calculation_ASILUC.vcd");
    $dumpvars(0, tb);

    // Reset active low
    repeat (2) @(negedge clk);
    rst_n = 1'b1;

    // ADDITION: command 0001
    run_test("ADD 10 + 5",    8'd10,  8'd5,  4'b0001, 16'd15, 1'b0);
    run_test("ADD 255 + 1",   8'd255, 8'd1,  4'b0001, 16'd256, 1'b0);

    // SUBTRACTION: command 0010
    run_test("SUB 10 - 5",    8'd10,  8'd5,  4'b0010, 16'd5,  1'b0);
    run_test("SUB 5 - 10",    8'd5,   8'd10, 4'b0010, 16'hFFFB, 1'b0);

    // MULTIPLICATION: command 0011
    run_test("MUL 10 * 5",    8'd10,  8'd5,  4'b0011, 16'd50, 1'b0);
    run_test("MUL 255 * 255", 8'd255, 8'd255,4'b0011, 16'd65025, 1'b0);

    // DIVISION: command 0100
    run_test("DIV 10 / 5",    8'd10,  8'd5,  4'b0100, 16'd2,  1'b0);
    run_test("DIV 7 / 2",     8'd7,   8'd2,  4'b0100, 16'd3,  1'b0);

    // DIVISION BY ZERO: command 0100
    run_test("DIV 10 / 0",    8'd10,  8'd0,  4'b0100, 16'd00000001,  1'b1);
    run_test("DIV 0 / 0",     8'd0,   8'd0,  4'b0100, 16'd00000001,  1'b1);

    // NOP: command 0000
    run_test("NOP 10, 5",     8'd10,  8'd5,  4'b0000, 16'd0,  1'b0);
    run_test("NOP 255, 255",  8'd255, 8'd255,4'b0000, 16'd0,  1'b0);

    // RESERVED: command 0101
    run_test("RESERVED 0101 A", 8'd10, 8'd5, 4'b0101, 16'd0, 1'b0);
    run_test("RESERVED 0101 B", 8'd0,  8'd0, 4'b0101, 16'd0, 1'b0);

    // Summary
    $display("");
    $display("==================================");
    $display("TEST SUMMARY");
    $display("Passed: %0d", passed);
    $display("Failed: %0d", failed);
    $display("Total:  %0d", passed + failed);
    $display("==================================");

    if (failed != 0)
      $fatal(1, "TEST SUITE FAILED");
    else
      $display("ALL TESTS PASSED SUCCESSFULLY");

    $finish;
  end

endmodule

`default_nettype wire
