# syntax=docker/dockerfile:1.3-labs
ARG BASE_IMAGE=ubuntu:focal
FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND=noninteractive

# https://www.nasm.us/
ARG NASM_VERSION=2.15.05
# https://code.videolan.org/videolan/x264.git
ARG LIBX264_VERSION=baee400fa9ced6f5481a728138fed6e867b0ff7f
# https://bitbucket.org/multicoreware/x265_git.git
# ARG LIBX265_VERSION=Release_3.5
# https://chromium.googlesource.com/webm/libvpx.git
ARG LIBVPX_VERSION=v1.12.0
# https://github.com/mstorsjo/fdk-aac.git
ARG AAC_VERSION=v2.0.2
# https://sourceforge.net/projects/lame/files/
ARG LAME_VERSION=3.100
# https://github.com/xiph/opus.git
ARG OPUS_VERSION=v1.3.1
# https://aomedia.googlesource.com/aom.git
ARG AOM_VERSION=v3.4.0
# https://ffmpeg.org/download.html
ARG FFMPEG_VERSION=5.1

ARG SOURCE_PREFIX=/ffmpeg_sources
ARG INSTALL_PREFIX=/usr/local

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# dependencies
RUN <<EOF
    apt-get update
    apt-get -y install \
        autoconf \
        automake \
        build-essential \
        cmake \
        git \
        libass-dev \
        libfreetype6-dev \
        libgnutls28-dev \
        libsdl2-dev \
        libtool \
        libva-dev \
        libvdpau-dev \
        libvorbis-dev \
        libxcb1-dev \
        libxcb-shm0-dev \
        libxcb-xfixes0-dev \
        pkg-config \
        texinfo \
        wget \
        yasm \
        zlib1g-dev
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# nasm
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/nasm
    cd ${SOURCE_PREFIX}/
    wget -O nasm.tar.bz2 https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2
    tar xjvf ./nasm.tar.bz2 -C ./nasm --strip-components 1
    cd ./nasm
    ./autogen.sh
    ./configure --prefix="${INSTALL_PREFIX}"
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/nasm
EOF

# libx264
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libx264
    cd ${SOURCE_PREFIX}/libx264
    git clone https://code.videolan.org/videolan/x264.git ./
    git checkout ${LIBX264_VERSION}
    ./configure --prefix="${INSTALL_PREFIX}" --enable-static --enable-pic
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libx264
EOF

# libx265
RUN <<EOF
    apt-get update
    apt-get install -y \
        libx265-dev \
        libnuma-dev
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# broken manual builds
# RUN <<EOF
#     mkdir -p ${SOURCE_PREFIX}/libx265
#     cd ${SOURCE_PREFIX}/libx265
#     apt-get install libnuma-dev
#     git clone --depth 1 --branch ${LIBX265_VERSION} https://bitbucket.org/multicoreware/x265_git.git ./
#     cd ./build/linux
#     cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off ../../source
#     make -j$(nproc)
#     make install
#     rm -rf ${SOURCE_PREFIX}/libx265
# EOF

# libvpx
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libvpx
    cd ${SOURCE_PREFIX}/libvpx
    git clone --depth 1 --branch ${LIBVPX_VERSION} https://chromium.googlesource.com/webm/libvpx.git ./
    ./configure --prefix="${INSTALL_PREFIX}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libvpx
EOF

# libfdk-aac
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libfdk-aac
    cd ${SOURCE_PREFIX}/libfdk-aac
    git clone --depth 1 --branch ${AAC_VERSION} https://github.com/mstorsjo/fdk-aac.git ./
    autoreconf -fiv
    ./configure --prefix="${INSTALL_PREFIX}" --disable-shared
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libfdk-aac
EOF

# libmp3lame
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libmp3lame
    cd ${SOURCE_PREFIX}/
    wget -O lame.tar.gz https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz
    tar xzvf lame.tar.gz -C ./libmp3lame --strip-components 1
    cd ./libmp3lame/
    ./configure --prefix="${INSTALL_PREFIX}" --disable-shared --enable-nasm
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libmp3lame
EOF

# libopus
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libopus
    cd ${SOURCE_PREFIX}/libopus
    git clone --depth 1 --branch ${OPUS_VERSION} https://github.com/xiph/opus.git ./
    ./autogen.sh
    ./configure --prefix="${INSTALL_PREFIX}" --disable-shared
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libopus
EOF

# libaom
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/libaom
    cd ${SOURCE_PREFIX}/libaom
    git clone --depth 1 --branch ${AOM_VERSION} https://aomedia.googlesource.com/aom.git ./
    mkdir aom_build
    cd aom_build
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off -DENABLE_NASM=on ../
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libaom
EOF

# ffmpeg
RUN <<EOF
    mkdir -p ${SOURCE_PREFIX}/ffmpeg
    cd ${SOURCE_PREFIX}/
    wget -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
    tar xjvf ffmpeg.tar.bz2 -C ./ffmpeg --strip-components 1
    cd ./ffmpeg
    ./configure \
        --prefix="${INSTALL_PREFIX}" \
        --pkg-config-flags="--static" \
        --extra-libs="-lpthread -lm" \
        --enable-gpl \
        --enable-libaom \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/ffmpeg
EOF

ENTRYPOINT [ "ffmpeg" ]
CMD [ "--help" ]
