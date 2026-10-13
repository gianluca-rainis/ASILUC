
`default_nettype none
`timescale 1ns / 1ps

module tb;

  reg run = 1'b0;
  reg clk = 1'b0;
  reg rst_n = 1'b0;

  wire last_cycle;

  integer passed = 0;
  integer failed = 0;

  // Device Under Test
  phase_timer_ASILUC user_project (
    .run(run),
    .clk(clk),
    .rst_n(rst_n),
    .last_cycle(last_cycle)
  );

  // Clock: 10 ns period
  always #5 clk = ~clk;

  // Check the expected value of last_cycle
  task check_output;
    input [8*40-1:0] test_name;
    input expected;

    begin
      #1;

      if (last_cycle !== expected) begin
        $display(
          "FAIL: %0s | run=%b last_cycle=%b expected=%b",
          test_name, run, last_cycle, expected
        );
        failed = failed + 1;
      end else begin
        $display(
          "PASS: %0s | run=%b last_cycle=%b",
          test_name, run, last_cycle
        );
        passed = passed + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("tb_phase_timer_ASILUC.vcd");
    $dumpvars(0, tb);

    // Reset active low
    repeat (2) @(negedge clk);
    check_output("RESET", 1'b0);

    rst_n = 1'b1;

    // Keep run low: output must remain low
    @(negedge clk);
    run = 1'b0;
    check_output("IDLE", 1'b0);

    // Start counting
    @(negedge clk);
    run = 1'b1;
    check_output("COUNT CYCLE 1", 1'b0);

    @(negedge clk);
    check_output("COUNT CYCLE 2", 1'b0);

    @(negedge clk);
    check_output("COUNT CYCLE 3", 1'b1);

    // Counter wraps back to zero
    @(negedge clk);
    check_output("COUNTER RESTART", 1'b0);

    @(negedge clk);
    check_output("SECOND CYCLE 2", 1'b0);

    @(negedge clk);
    check_output("SECOND CYCLE 3", 1'b1);

    // Stop timer: output must go low
    @(negedge clk);
    run = 1'b0;
    check_output("STOP TIMER", 1'b0);

    // Restart should begin a fresh counting sequence
    @(negedge clk);
    run = 1'b1;
    check_output("RESTART CYCLE 1", 1'b0);

    @(negedge clk);
    check_output("RESTART CYCLE 2", 1'b0);

    @(negedge clk);
    check_output("RESTART CYCLE 3", 1'b1);

    // Assert reset while timer is running
    @(negedge clk);
    rst_n = 1'b0;
    check_output("RESET WHILE RUNNING", 1'b0);

    // Release reset and check fresh sequence
    @(negedge clk);
    rst_n = 1'b1;
    check_output("AFTER RESET CYCLE 1", 1'b0);

    @(negedge clk);
    check_output("AFTER RESET CYCLE 2", 1'b0);

    @(negedge clk);
    check_output("AFTER RESET CYCLE 3", 1'b1);

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
