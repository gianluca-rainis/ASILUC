# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
# -------------------------------------------
# Copyright (c) 2026 Gianluca Rainis

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    command = 1                                 # Change the command to execute here
    number1 = 201                               # Change the first number of the operation here (0-255)
    number2 = 90                                # Change the second number of the operation here (0-255)
    operation_result = int(number1 + number2)   # Change the operation here (+, -, *, /, ...)
    expected_output_low = (operation_result) & 0xFF
    expected_output_high = (operation_result) >> 8

    whileCounter = 0

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
    await ClockCycles(dut.clk, 3)

    # Command input
    dut._log.info("Command input: {}".format(command))
    dut.uio_in.value = command
    await ClockCycles(dut.clk, 3)

    while whileCounter < 20:
        if int(dut.uio_out.value) >> 4 == 0b0100:
            # Number input 1
            dut._log.info("Number input 1: {}".format(number1))
            dut.ui_in.value = number1
            await ClockCycles(dut.clk, 3)

            break
        else:
            dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
            await ClockCycles(dut.clk, 1)

        whileCounter += 1

    assert whileCounter < 20, "Timeout waiting for number input 1 state"
    whileCounter = 0

    while whileCounter < 20:
        if int(dut.uio_out.value) >> 4 == 0b0110:
            # Number input 2
            dut._log.info("Number input 2: {}".format(number2))
            dut.ui_in.value = number2
            await ClockCycles(dut.clk, 3)

            break
        else:
            dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
            await ClockCycles(dut.clk, 1)

        whileCounter += 1

    assert whileCounter < 20, "Timeout waiting for number input 2 state"
    whileCounter = 0

    while whileCounter < 20:
        if int(dut.uio_out.value) >> 4 == 0b1000:
            # Calculating output
            dut._log.info("Calculating output")
            await ClockCycles(dut.clk, 1)

            break
        else:
            dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
            await ClockCycles(dut.clk, 1)

        whileCounter += 1

    assert whileCounter < 20, "Timeout waiting for calculating output state"
    whileCounter = 0

    dut._log.info("Output expected: {}".format(operation_result))

    while whileCounter < 20:
        if int(dut.uio_out.value) >> 4 == 0b1100:
            # Check output low
            dut._log.info("Check output low: {}".format(expected_output_low))
            assert int(dut.uo_out.value) == expected_output_low
            await ClockCycles(dut.clk, 3)

            break
        else:
            dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
            await ClockCycles(dut.clk, 1)

        whileCounter += 1

    assert whileCounter < 20, "Timeout waiting for check output low state"
    whileCounter = 0

    while whileCounter < 20:
        if int(dut.uio_out.value) >> 4 == 0b1110:
            # Check output high
            dut._log.info("Check output high: {}".format(expected_output_high))
            assert int(dut.uo_out.value) == expected_output_high
            await ClockCycles(dut.clk, 3)

            break
        else:
            dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
            await ClockCycles(dut.clk, 1)

        whileCounter += 1

    assert whileCounter < 20, "Timeout waiting for check output high state"

    if int(dut.uio_out.value) >> 4 == 0b0001:
        # Error
        dut._log.info("Error: {}".format(int(dut.uo_out.value)))
        # assert False, "Error occurred during processing"
        await ClockCycles(dut.clk, 3)

    if int(dut.uio_out.value) >> 4 == 0b0000:
        # NOP
        dut._log.info("NOP")
        await ClockCycles(dut.clk, 1)
    else:
        dut._log.info("   Unexpected state: {}".format(int(dut.uio_out.value)))
        await ClockCycles(dut.clk, 1)

    assert int(dut.uio_out.value) >> 4 == 0b0000, "Unexpected state after processing"

