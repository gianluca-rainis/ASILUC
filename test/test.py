# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    command = 1
    number1 = 20
    number2 = 5
    expected_output_low = bin((number1 + number2) & 0x0F)
    expected_output_high = bin((number1 + number2) >> 8)

    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Command input
    dut.uio_in.value = command
    await ClockCycles(dut.clk, 3)

    # Number input 1
    dut.ui_in.value = number1
    await ClockCycles(dut.clk, 3)

    # Number input 2
    dut.ui_in.value = number2
    await ClockCycles(dut.clk, 3)

    # Check output
    assert dut.uo_out.value == expected_output_low
    await ClockCycles(dut.clk, 3)
    assert dut.uo_out.value == expected_output_high
    await ClockCycles(dut.clk, 3)

