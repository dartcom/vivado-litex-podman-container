# vivado-litex-podman-container
A podman container with vivado, litex, verilator, openfpgaloader


## Instructions:
1. You will need to provide your own vivado unified installer (the big one). Place the .tar inside  `installer-vol` folder. Add the name of the tarball to the `VIVADOINSTALLNAME` value on the Makefile and Containerfile.

2. Run `make gen-vivado-cfg` and follow the instructions of xsetup. `install_config.txt` should appear under `installer-vol`. As of Vivado 2025.1, I had to specify the devices I wanted to support on the .txt file.

3. Run `make build-vivado-litex` to build the image. For vivado 2025.1, for artix devices the size of the image was 74gb.
