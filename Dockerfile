FROM ubuntu:20.04

ARG GCC_ARM_NAME=gcc-arm-none-eabi-10-2020-q4-major
ARG CMAKE_VERSION=3.22.2
ARG WGET_ARGS="-q --show-progress --progress=bar:force:noscroll --no-check-certificate"

ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install --no-install-recommends -y \
	gnupg \
	ca-certificates && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
	echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
	apt-get -y update && \
	apt-get install --no-install-recommends -y \
	autoconf \
	automake \
	bison \
	build-essential \
	dos2unix \
	doxygen \
	file \
	flex \
	g++ \
	gawk \
	gcc \
	gcc-multilib \
	g++-multilib \
	gcovr \
	git \
	git-core \
	gperf \
    graphviz \
	gtk-sharp2 \
	libncurses5-dev \
	libopenal-dev \
	libpcap-dev \
	libsdl2-dev:i386 \
	libsdl1.2-dev \
	libsdl2-dev \
	libsdl2-gfx-dev \
	libsdl2-image-dev \
	libsdl2-mixer-dev \
	libsdl2-net-dev \
	libsdl2-ttf-dev \
	libssl-dev \
	libwxgtk3.0-gtk3-dev \
	locales \
	make \
	nano \
	ninja-build \
	openssh-client \
	pkg-config \
	protobuf-compiler \
	python3-dev \
	python3-pip \
	python3-ply \
	python3-setuptools \
	python-is-python3 \
	qemu \
	rsync \
	socat \
	srecord \
	sudo \
	texinfo \
	unzip \
	valgrind \
	wget \
	byacc \
	flex \
	xa65 \
	dos2unix \
	texinfo \
	texlive-fonts-recommended \
	cc65 \
	64tass \
	xz-utils && \
	rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN pip3 install wheel pip -U &&\
	pip3 install sh &&\
	pip3 install pylint pyserial \
		     statistics numpy \
		     imgtool \
		     protobuf


RUN mkdir -p /opt/toolchains

RUN wget ${WGET_ARGS} https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/${GCC_ARM_NAME}-x86_64-linux.tar.bz2  && \
	tar -xf ${GCC_ARM_NAME}-x86_64-linux.tar.bz2 -C /opt/toolchains/ && \
	rm -f ${GCC_ARM_NAME}-x86_64-linux.tar.bz2

RUN wget ${WGET_ARGS} https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \
	chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \
	./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
	rm -f ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh

RUN apt-get clean && \
	sudo apt-get autoremove --purge

RUN groupadd -g $GID -o user

RUN useradd -u $UID -m -g user -G plugdev user \
	&& echo 'user ALL = NOPASSWD: ALL' > /etc/sudoers.d/user \
	&& chmod 0440 /etc/sudoers.d/user

RUN wget ${WGET_ARGS} https://static.rust-lang.org/rustup/rustup-init.sh && \
	chmod +x rustup-init.sh && \
	./rustup-init.sh -y && \
	. $HOME/.cargo/env && \
	cargo install uefi-run --root /usr && \
	rm -f ./rustup-init.sh

USER root

# Set the locale
ENV GNUARMEMB_TOOLCHAIN_PATH=/opt/toolchains/${GCC_ARM_NAME}
ENV PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig
ENV OVMF_FD_PATH=/usr/share/ovmf/OVMF.fd