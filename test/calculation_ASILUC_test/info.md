# Testing calculation_ASILUC
To test the `calculation_ASILUC` module run the following commands from `/test/calculation_ASILUC_test`.

Make sure to have installed on your machine the [OSS CAD Suite](https://github.com/yosyshq/oss-cad-suite-build).

## Create sim_calculation_ASILUC and tb_calculation_ASILUC.vcd
```bash
iverilog -g2012 -Wall -s tb -o sim_calculation_ASILUC tb_calculation_ASILUC.v ../../src/calculation_ASILUC.v
```

## Run the tests
```bash
vvp sim_calculation_ASILUC
```

## Visualize the waveforms
```bash
gtkwave tb_calculation_ASILUC.vcd
```
