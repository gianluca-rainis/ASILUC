<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
The ASILUC uses:
- `[7:0] ui_in` as input for the two 1 byte numbers to perform the operation on.
- `[7:0] uo_out` as output for the 2 byte result of the operation, presented one byte at a time.
- `[7:0] uio_oe` as `8'b11110000`.
- `[7:0] uio_in` where only the 4 lowest bits are used to read the command associated with the operation to be performed.
- `[7:0] uio_out` where only the 4 highest bits are used to signal the current status of ASILUC.

### Bits Tables
#### `uio_out` bits status table
|Operation|busy (`uio_out[7]`)|status (`uio_out[6]`)|highByte (`uio_out[5]`)|error (`uio_out[4]`)|
|---|---|---|---|---|
|Idle|0|0|0|0|
|Command Accepted|0|1|0|0|
|Input (first number)|0|1|0|0|
|Input (second number)|0|1|1|0|
|Calculating|1|0|0|0|
|Output (lowest byte)|1|1|0|0|
|Output (highest byte)|1|1|1|0|
|Error|0|0|0|1|

---

#### `uio_in` bits commands table
|Command|`uio_in[3:0]`|
|---|---|
|`NOP`|`0000`|
|`SUM`|`0001`|
|`SUB`|`0010`|
|`MUL`|`0011`|
|`DIV`|`0100`|
|`Reserved` (handled as `NOP`)|`0101`-`1111`|

---

#### Error codes table
|Error|`uo_out[3:0]`|
|---|---|
|Generic Error|`0000`|
|Div 0|`0001`|
|Unused (if one occurs, it is treated as Generic Error)|`0010`-`1111`|

### ASILUC behavior
ASILUC's default behavior is `NOP`. In this status, all inputs (`ui_in`) are ignored.

When `uio_in` strictly changes from `NOP` to one of the operations, ASILUC starts the command reading: it waits **three clock cycles** to read the command associated with the operation to be executed, so the signal has time to stabilize, preventing errors.
Once ASILUC reads the command, it reads the first 8-bit number from `ui_in` for **3 cycles** (the value saved is the one on the third cycle), and then, it reads the second 8-bit number for **3 cycles**.

`uio_in` ignores any unexpected command changes: the command read on the third cycle after the change from `NOP` is the one executed.

Meanwhile, `uio_out` uses the 4 bits to signal the status of ASILUC:
- `uio_out[7]`: *busy* - 1 if ASILUC is executing operations or if ASILUC put a result byte on `uo_out`.
- `uio_out[6]`: *status* - 1 if ASILUC put a result byte on `uo_out`, if ASILUC is reading a number on `ui_in`, or if the given command has been accepted.
- `uio_out[5]`: *highByte* - indicates whether the byte on `uo_out` is the high byte (2nd byte of out) or the low byte (1st byte of out), or indicates whether the read number on `ui_in` is the second or the first.
- `uio_out[4]`: *error* - 1 if an error occurred.

ASILUC processes the operation in the time it needs, maintaining *busy* at 1.
Once ASILUC finishes processing the operation, it sets *status* to 1 and puts the low byte of the result on `uo_out` (which, until this point, has always been `0x00`) (*highByte* at 0) (keeps the low byte stable for **3 cycles**), and then the high byte of the result (*highByte* at 1) (keeps it stable for **3 cycles**).

Afterwards, it returns with *busy* at 0, *status* at 0, *highByte* at 0, *error* at 0, and `uo_out` at `0x00`.

The process restarts, listening to `uio_in` again.

Some additional details:
- While the command is `NOP`, ASILUC stays in the Idle phase.
- In Idle ASILUC looks for changes on `uio_in[3:0]`.
- If the command read in the third cycle is `NOP` or `Reserved`, ASILUC returns to Idle without starting any transaction or operation.
- If an error occurs during execution, *busy* goes to 0, *status* goes to 0, *highByte* to 0, and *error* to 1. The error code, associated with the type of error that occurred, is set to `uo_out[3:0]`. It waits *3 clock cycles* like this and then returns to normal.

### ASILUC behavior Table
|Sequence|Operation|Duration (clk)|busy|status|highByte|error|
|---|---|---|---|---|---|---|
|Ø|Idle|∞|0|0|0|0|
|0|Command Reading|0-2|0|0|0|0|
|1|Command Accepted|3-5|0|1|0|0|
|2|Input (first number)|6-8|0|1|0|0|
|3|Input (second number)|9-11|0|1|1|0|
|4|Calculating|Variable|1|0|0|0|
|5|Output (lowest byte)|0-2 (After Calculating)|1|1|0|0|
|6|Output (highest byte)|3-5 (After Calculating)|1|1|1|0|
|Ø|Error|0-2|0|0|0|1|

## How to test
Explain how to use your project

## External hardware
List external hardware used in your project
