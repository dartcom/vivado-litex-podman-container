# vivado-litex-podman-container
A podman container with vivado, litex, verilator, openfpgaloader, 


- You will need to provide your own vivado unified installer (the big one).
 
- Place the .tar inside  `installer-vol` folder. Add the name of the tarball to the `VIVADO_INSTALL_NAME` value on the Makefile and Containerfile.

- Specify the Vivado config file name on `VIVADO_CONFIG_FILE` on the Makefile and Containerfile.

- Specify the name of the Vivado version on `VIVADO_VER` on the Makefile and Containerfile, e.g. `2025.1`

-  Run `make gen-vivado-cfg` and follow the instructions of xsetup. `install_config.txt` should appear under `installer-vol`. As of Vivado 2025.1, I had to specify the devices I wanted to support on the .txt file.

- Run `make build-vivado-litex` to build the image. For vivado 2025.1, for artix devices the size of the image was 74gb.
- If the build process hangs, after quitting the container, you will have to kill it, otherwise it will take space. Run `podman ps --external` to find the container, and `podman rm **your image tag here** --force` to kill it.
