# Simulation

`tb_system.v` is the current image-stream testbench. It expects `input_image.hex` in the simulator working directory and emits `enhanced_image.ppm` and `output_image.hex`. The input file is intentionally not committed because it is generated from a dataset image. Follow the Vivado instructions in the root README and keep the testbench width consistent with `IMG_W` in the RTL top module.
