# Testing phase_timer_ASILUC
To test the `phase_timer_ASILUC` module run the following commands from `/test/phase_timer_ASILUC`.

Make sure to have installed on your machine the [OSS CAD Suite](https://github.com/yosyshq/oss-cad-suite-build).

## Create sim_phase_timer_ASILUC and tb_phase_timer_ASILUC.vcd
```bash
iverilog -g2012 -Wall -s tb -o sim_phase_timer_ASILUC tb_phase_timer_ASILUC.v ../../src/phase_timer_ASILUC.v
```

## Run the tests
```bash
vvp sim_phase_timer_ASILUC
```

## Visualize the waveforms
```bash
gtkwave tb_phase_timer_ASILUC.vcd
```
