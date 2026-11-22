# Testing ASILUC on an Icepi Zero
To test ASILUC on an Icepi Zero you have to follow the following instructions:

1. Install on your machine the [OSS CAD Suite](https://github.com/yosyshq/oss-cad-suite-build).
2. From the ASILUC repo's root, go to `/fpga/icepi-zero`.
3. Clone the `icepi-zero` official repository:
    ```bash
    git clone https://github.com/cheyao/icepi-zero.git
    ```
4. Enter in the OSS CAD Suite environment:
    ```bash
    source /{PATH}/oss-cad-suite/environment
    ```
5. Make the *Icepi Zero ASILUC's testing* with the following commands:
    If there's already a previous build, run:
    ```bash
    make clean
    ```
    To rebuild the *Icepi Zero ASILUC's testing* with:
    ```bash
    make build
    ```
6. Connect your Icepi Zero to your computer. You can check if it's available with:
    ```bash
    openFPGALoader -b icepi-zero --detect
    ```
7. Load the compiled program in the Icepi Zero with:
    ```bash
    openFPGALoader -b icepi-zero build/asiluc.bit
    ```
