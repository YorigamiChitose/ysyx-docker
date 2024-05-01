FROM ubuntu:22.04

ARG APPDIR=/root
WORKDIR ${APPDIR}

RUN echo "# By default, mirror sources are disabled. If needed, please uncomment them manually." >> /etc/apt/sources.list \
    && echo "# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt update && apt upgrade -y && apt install -y \
    build-essential git man gcc-doc gdb libreadline-dev libsdl2-dev llvm llvm-dev vim \
    g++-riscv64-linux-gnu binutils-riscv64-linux-gnu device-tree-compiler \
    openjdk-17-jdk wget curl help2man perl python3 cmake make autoconf neofetch \
    flex bison ccache libgoogle-perftools-dev numactl perl-doc \
    libfl2 zlib1g zlib1g-dev


ARG VERILATOR_VERSION=v5.008
ARG MAKE_J=4

RUN git clone https://github.com/verilator/verilator.git \
    && cd ${APPDIR}/verilator \
    && git checkout ${VERILATOR_VERSION} \
    && autoconf \
    && ./configure \
    && make -j${MAKE_J} \
    && make test \
    && make install \
    && cd ${APPDIR} \
    && rm -rf verilator

RUN git config --global user.email "test@test.com" \
    && git config --global user.name "test"

ARG YSYX=ysyx-workbench-default

RUN git clone https://github.com/OSCPU/ysyx-workbench.git ${YSYX} \
    && cd ${APPDIR}/${YSYX} \
    && sed -i 's!git@github.com:!https://github.com/!g' init.sh \
    && bash init.sh nemu \
    && bash init.sh am-kernels \
    && bash init.sh abstract-machine \
    && bash init.sh navy-apps \
    && sed -i 's!git@github.com:!https://github.com/!g' `grep -rl git@github.com: .` \
    && cd ${APPDIR}/${YSYX}/navy-apps/apps/pal \
    && git clone --depth=1 https://github.com/NJU-ProjectN/pal-navy.git repo \
    && mkdir ${APPDIR}/${YSYX}/navy-apps/apps/pal/repo/data \
    && cd ${APPDIR}/${YSYX}/navy-apps/apps/pal/repo/data \
    && wget https://box.nju.edu.cn/f/73c08ca0a5164a94aaba/\?dl\=1 -O pal-data-new.tar.bz2 \
    && tar -jxvf pal-data-new.tar.bz2 \
    && rm pal-data-new.tar.bz2 \
    && cd ${APPDIR}/${YSYX}/navy-apps/libs \
    && git clone https://github.com/NJU-ProjectN/newlib-navy.git libc \
    && cd ${APPDIR}/${YSYX}/navy-apps/apps/bird \
    && git clone --depth=1 https://github.com/NJU-ProjectN/sdlbird.git repo \
    && cd ${APPDIR}/${YSYX}/nemu/tools/spike-diff \
    && git clone --depth=1 https://github.com/NJU-ProjectN/riscv-isa-sim.git repo

ARG OLD_MILL=0.10.15

RUN git clone https://github.com/lefou/millw.git \
    && ln -sf ${APPDIR}/millw/millw /usr/bin/mill \
    && mill --version \
    && MILL_VERSION=${OLD_MILL} mill --version

RUN git clone https://github.com/OpenXiangShan/chisel-playground.git \
    && cd ${APPDIR}/chisel-playground \
    && make test \
    && MILL_VERSION=${OLD_MILL} make test
