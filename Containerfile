FROM ubuntu:22.04

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

ARG VIVADO_INSTALL_NAME=FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_1114_2157
ARG VIVADO_VER=2025.2
ARG VIVADO_CONFIG_FILE=install_config.txt

ARG OPENFPGALOADER_VER=v1.0.0 


COPY installer-vol/${VIVADO_INSTALL_NAME} /tmp/${VIVADO_INSTALL_NAME} 
COPY installer-vol/${VIVADO_CONFIG_FILE} /tmp/${VIVADO_INSTALL_NAME}/
COPY start.sh .

#STEP 1
RUN mkdir /workspaces && \ 
    chmod +x /start.sh

RUN apt update && \
    apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive TZ=America/New_York apt install -y \ 
        build-essential clang bison flex cmake git libreadline-dev \ 
        gawk tcl-dev libffi-dev pkg-config python3 libboost-system-dev \ 
        libboost-python-dev libboost-filesystem-dev zlib1g-dev libtcl8.6 \ 
        graphviz xdot gfortran python3-dev libpython3-dev \ 
        pip \ 
        python3-yaml libboost-all-dev libeigen3-dev curl gnutls-bin openssl \ 
        libgomp1 python3.10-venv \ 
        default-jre-headless uuid-dev libantlr4-runtime-dev wget \ 
        help2man perl g++ ccache mold autoconf flex bison libfl2 libfl-dev \ 
        ca-certificates tree less bzip2 zip make mc gzip libftdi1-2 libftdi1-dev \ 
        libhidapi-hidraw0 libhidapi-dev libudev-dev gpiod libgpiod-dev \ 
        lld texinfo automake nasm doxygen dos2unix xz-utils \ 
        sudo libtool libmpc-dev ftp ninja-build \ 
        libjim-dev libjaylink-dev libjaylink0 libusb-1.0-0-dev nano tree locales libtinfo5 libtinfo-dev && \ 
        update-ca-certificates
        
#STEP 2
RUN mkdir /tmp/tmp-build && \ 
    locale && \ 
    locale-gen "en_US.UTF-8" && \ 
    update-locale LANG=en_US.UTF-8 

#STEP 3
RUN cd /tmp/${VIVADO_INSTALL_NAME} && \ 
    ./xsetup -a XilinxEULA,3rdPartyEULA -b Install -c ${VIVADO_CONFIG_FILE} && \ 
    cd /tools/Xilinx/${VIVADO_VER}/Vivado/scripts && \ 
    ./installLibs.sh

#STEP 4
RUN cd /tmp/tmp-build && \ 
    git clone https://github.com/openocd-org/openocd.git && \ 
    cd openocd && \ 
    ./bootstrap && \ 
    ./configure --enable-ch347 --enable-cmsis-dap-v2 --enable-cmsis-dap --enable-openjtag && \ 
    make -j$(nproc) && \ 
    make install 

#STEP 5
RUN cd /tmp/tmp-build && \ 
    git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git && \ 
    cd riscv-gnu-toolchain && \ 
    mkdir build && \ 
    cd build && \ 
    ../configure --prefix=/opt/riscv32-unknown-elf --disable-linux --with-arch=rv32imafdc --with-abi=ilp32f && \ 
    make -j$(nproc) && \ 
    make install

RUN pip3 install meson 

#STEP 6
RUN cd /tmp && \ 
    git clone --recursive --depth=1 https://github.com/enjoy-digital/litex && \ 
    cd litex && \ 
    ./litex_setup.py --init --install --config=full


#STEP 7
RUN cd /tmp/tmp-build && \ 
    git clone https://github.com/verilator/verilator && \ 
    cd verilator && \ 
    git checkout stable && \ 
    autoconf && \ 
    ./configure && \ 
    make -j `nproc` && \ 
    make install

# openFPGALoader
#STEP 8
RUN cd /tmp/tmp-build && \ 
    git clone https://github.com/trabucayre/openFPGALoader --branch ${OPENFPGALOADER_VER} && \ 
    cd openFPGALoader && \ 
    mkdir build && \ 
    cd build && \ 
    cmake .. && \ 
    cmake --build . && \ 
    make install


# cleanup 
#STEP 9
RUN rm -rf /tmp/tmp-build && \ 
    rm -rf /tmp/${VIVADO_INSTALL_NAME} && \ 
    pip cache purge && \ 
    apt-get autoclean && apt-get clean && apt-get -y autoremove
    

ENTRYPOINT ["./start.sh"]

ENV PATH=/opt/riscv32-unknown-elf/bin:$PATH