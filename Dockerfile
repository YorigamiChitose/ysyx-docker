FROM ubuntu:22.04

ARG APPDIR=/app
WORKDIR ${APPDIR}

RUN apt update && apt upgrade -y && apt install -y \
    build-essential git man gcc-doc gdb libreadline-dev libsdl2-dev llvm llvm-dev vim \
    g++-riscv64-linux-gnu binutils-riscv64-linux-gnu device-tree-compiler \
    openjdk-17-jdk wget curl help2man perl python3 make autoconf \
    flex bison ccache libgoogle-perftools-dev numactl perl-doc \
    libfl2 zlib1g zlib1g-dev


RUN git clone https://github.com/verilator/verilator.git \
    && cd ${APPDIR}/verilator \
    && git checkout v5.008 \
    && autoconf \
    && ./configure \
    && make -j4 \
    && make install \
    && cd ${APPDIR} \
    && rm -rf verilator

RUN git config --global user.email "test@test.com" \
    && git config --global user.name "test"

RUN git clone https://github.com/OSCPU/ysyx-workbench.git ysyx-workbench-default \
    && cd ${APPDIR}/ysyx-workbench-default \
    && bash init.sh nemu \
    && bash init.sh am-kernels \
    && bash init.sh navy-apps \
    && cd ${APPDIR}/ysyx-workbench-default/navy-apps/apps/pal \
    && git clone --depth=1 https://github.com/NJU-ProjectN/pal-navy.git repo \
    && mkdir ${APPDIR}/ysyx-workbench-default/navy-apps/apps/pal/repo/data \
    && cd ${APPDIR}/ysyx-workbench-default/navy-apps/apps/pal/repo/data \
    && wget https://box.nju.edu.cn/f/73c08ca0a5164a94aaba/\?dl\=1 -O pal-data-new.tar.bz2 \
    && tar -jxvf pal-data-new.tar.bz2 \
    && rm pal-data-new.tar.bz2 \
    && cd ${APPDIR}/ysyx-workbench-default/navy-apps/libs \
    && git clone https://github.com/NJU-ProjectN/newlib-navy.git libc \
    && cd ${APPDIR}/ysyx-workbench-default/navy-apps/apps/bird \
    && git clone --depth=1 https://github.com/NJU-ProjectN/sdlbird.git repo \
    && cd ${APPDIR}/ysyx-workbench-default/nemu/tools/spike-diff \
    && git clone --depth=1 https://github.com/NJU-ProjectN/riscv-isa-sim.git repo

RUN git clone https://github.com/lefou/millw.git \
    && ln -sf ${APPDIR}/millw/millw /usr/bin/mill \
    && mill --version

RUN git clone https://github.com/OpenXiangShan/chisel-playground.git \
    && cd ${APPDIR}/chisel-playground \
    && make test