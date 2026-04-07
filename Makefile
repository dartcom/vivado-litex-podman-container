.PHONY: run-vivado-litex build-vivado-litex clean-vivado-litex start-script

OWNER:= $(shell whoami)
CONTAINER_NAME:=$(OWNER)/vivado-litex

VIVADO_INSTALL_NAME:= FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_1114_2157
VIVADO_VER:=2025.2
VIVADO_CONFIG_FILE:= install_config.txt

PATH_REL = $(shell git rev-parse --show-prefix)
PATH_GIT = $(shell git rev-parse --show-toplevel)
PATH_TOTAL = $(shell pwd)

start-script:
	echo '#!/bin/bash' > start.sh
	echo '. /tools/Xilinx/$(VIVADO_VER)/Vivado/settings64.sh' >> start.sh
	echo 'cd workspaces' >> start.sh
	echo 'exec "$$@"' >> start.sh
	chmod +x start.sh

untar-vivado:installer-vol/$(VIVADO_INSTALL_NAME)/xsetup
	tar -xvf installer-vol/$(VIVADO_INSTALL_NAME).tar -C installer-vol/ 

gen-vivado-cfg:untar-vivado
	./installer-vol/$(VIVADO_INSTALL_NAME)/xsetup -b ConfigGen
	cp ~/.Xilinx/install_config.txt installer-vol/

run-vivado-litex:
	podman run --rm --network=host --pid=host --pull=never -v /dev/:/dev/ -v $(PATH_GIT):/workspaces:z -it localhost/$(CONTAINER_NAME) /bin/bash

build-vivado-litex:start-script
	podman build --squash -t $(CONTAINER_NAME) . -f Containerfile --build-arg=VIVADO_INSTALL_NAME=$(VIVADO_INSTALL_NAME) --build-arg=VIVADO_VER=$(VIVADO_VER) --build-arg=VIVADOCONFIGFILE=$(VIVADOCONFIGFILE)
	
clean-vivado-litex:
	podman rmi -f localhost/$(CONTAINER_NAME)

