.PHONY: run-vivado-litex build-vivado-litex clean-vivado-litex 

OWNER:= $(shell whoami)
CONTAINERNAME:=$(OWNER)/vivado-litex

VIVADOINSTALLNAME:= FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_1114_2157
VIVADOCONFIGFILE:= install_config.txt

PATH_REL = $(shell git rev-parse --show-prefix)
PATH_GIT = $(shell git rev-parse --show-toplevel)
PATH_TOTAL = $(shell pwd)


untar-vivado:installer-vol/$(VIVADOINSTALLNAME)/xsetup
	tar -xvf installer-vol/$(VIVADOINSTALLNAME).tar -C installer-vol/ 

gen-vivado-cfg:untar-vivado
	./installer-vol/$(VIVADOINSTALLNAME)/xsetup -b ConfigGen
	cp ~/.Xilinx/install_config.txt installer-vol/

run-vivado-litex:
	podman run --rm --network=host --pid=host --pull=never -v /dev/:/dev/ -v $(PATH_GIT):/workspaces:z -it localhost/$(CONTAINERNAME) 

build-vivado-litex:
	podman build --squash -t $(CONTAINERNAME) . -f Containerfile --build-arg=VIVADOINSTALLNAME=$(VIVADOINSTALLNAME) --build-arg=VIVADOCONFIGFILE=$(VIVADOCONFIGFILE)
	
clean-vivado-litex:
	podman rmi -f localhost/$(CONTAINERNAME)

