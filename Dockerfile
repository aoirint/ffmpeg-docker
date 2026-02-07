# syntax=docker/dockerfile:1
ARG BASE_IMAGE=ubuntu:24.04
FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND=noninteractive

ARG SOURCE_PREFIX=/ffmpeg_sources
ARG INSTALL_PREFIX=/usr/local

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# dependencies
RUN <<EOF
    set -eux
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
        libunistring-dev \
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
        zlib1g-dev \
        unzip \
        python3 \
        python3-pip
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# nasm
# https://www.nasm.us/
ARG NASM_VERSION=2.16.03
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/nasm
    cd ${SOURCE_PREFIX}/
    wget -O nasm.tar.bz2 https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2
    tar xjvf ./nasm.tar.bz2 -C ./nasm --strip-components 1
    rm ./nasm.tar.bz2

    cd ./nasm
    ./autogen.sh
    ./configure --prefix="${INSTALL_PREFIX}"
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/nasm
EOF

# libx264
# https://code.videolan.org/videolan/x264.git
ARG LIBX264_VERSION=4613ac3c15fd75cebc4b9f65b7fb95e70a3acce1
RUN <<EOF
    set -eux
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
    set -eux
    apt-get update
    apt-get install -y \
        libx265-dev \
        libnuma-dev
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF

# broken manual builds
# https://bitbucket.org/multicoreware/x265_git.git
# ARG LIBX265_VERSION=Release_3.5
# RUN <<EOF
#     set -eux
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
# https://chromium.googlesource.com/webm/libvpx.git
ARG LIBVPX_VERSION=v1.14.1
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libvpx
    cd ${SOURCE_PREFIX}/libvpx
    git clone --depth 1 --branch ${LIBVPX_VERSION} https://chromium.googlesource.com/webm/libvpx.git ./
    ./configure --prefix="${INSTALL_PREFIX}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libvpx
EOF

# libfdk-aac
# https://github.com/mstorsjo/fdk-aac.git
ARG AAC_VERSION=v2.0.3
RUN <<EOF
    set -eux
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
# https://sourceforge.net/projects/lame/files/
ARG LAME_VERSION=3.100
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libmp3lame
    cd ${SOURCE_PREFIX}/
    wget -O ./lame.tar.gz https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz
    tar xzvf ./lame.tar.gz -C ./libmp3lame --strip-components 1
    rm ./lame.tar.gz

    cd ./libmp3lame/
    ./configure --prefix="${INSTALL_PREFIX}" --disable-shared --enable-nasm
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libmp3lame
EOF

# libopus
# https://github.com/xiph/opus.git
ARG OPUS_VERSION=v1.4
RUN <<EOF
    set -eux
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
# https://aomedia.googlesource.com/aom.git
ARG AOM_VERSION=v3.9.0
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libaom
    cd ${SOURCE_PREFIX}/libaom
    git clone --depth 1 --branch ${AOM_VERSION} https://aomedia.googlesource.com/aom.git ./
    mkdir aom_build
    cd aom_build
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off -DENABLE_TESTS=off -DENABLE_NASM=on ../
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/libaom
EOF

# libsvtav1
# https://gitlab.com/AOMediaCodec/SVT-AV1
ARG SVTAV1_VERSION=v2.1.0
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/SVT-AV1
    cd ${SOURCE_PREFIX}/SVT-AV1
    git clone --depth 1 --branch ${SVTAV1_VERSION} https://gitlab.com/AOMediaCodec/SVT-AV1.git ./
    mkdir build
    cd build
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF ../
    make -j$(nproc)
    make install
    rm -rf ${SOURCE_PREFIX}/SVT-AV1
EOF

# ninja
# https://github.com/ninja-build/ninja
ARG NINJA_VERSION=v1.12.1
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/ninja
    cd ${SOURCE_PREFIX}/ninja
    wget -O ./ninja-linux.zip "https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-linux.zip"
    unzip ./ninja-linux.zip
    rm ./ninja-linux.zip

    cp ninja "${INSTALL_PREFIX}/bin/"
    rm -rf ${SOURCE_PREFIX}/ninja
EOF

# meson
# https://github.com/mesonbuild/meson
ARG MESON_VERSION=1.4.1
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/meson
    cd ${SOURCE_PREFIX}/meson
    git clone --depth 1 --branch ${MESON_VERSION} https://github.com/mesonbuild/meson.git ./
    pip3 install --no-cache-dir .
    rm -rf ${SOURCE_PREFIX}/meson
EOF

# libdav1d
# https://code.videolan.org/videolan/dav1d
ARG DAV1D_VERSION=1.4.2
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/dav1d
    cd ${SOURCE_PREFIX}/dav1d
    git clone --depth 1 --branch ${DAV1D_VERSION} https://code.videolan.org/videolan/dav1d.git ./
    mkdir build
    cd build
    meson setup -Denable_tools=false -Denable_tests=false --default-library=static --prefix="${INSTALL_PREFIX}" --libdir="${INSTALL_PREFIX}/lib" ../
    ninja
    ninja install
    rm -rf ${SOURCE_PREFIX}/dav1d
EOF

# libvmaf
# https://github.com/Netflix/vmaf
ARG VMAF_VERSION=v3.0.0
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/vmaf
    cd ${SOURCE_PREFIX}/vmaf
    git clone --depth 1 --branch ${VMAF_VERSION} https://github.com/Netflix/vmaf.git ./
    cd libvmaf
    mkdir build
    cd build
    meson setup -Denable_tests=false -Denable_docs=false --buildtype=release --default-library=static --prefix="${INSTALL_PREFIX}" --bindir="${INSTALL_PREFIX}/bin" --libdir="${INSTALL_PREFIX}/lib" ../
    ninja
    ninja install
    rm -rf ${SOURCE_PREFIX}/vmaf
EOF

# NVIDIA video codec
# https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git
ARG ENABLE_NVCODEC=0
ARG NVCODEC_HEADER_VERSION=n12.2.72.0
RUN <<EOF
    set -eux

    if [ "${ENABLE_NVCODEC}" = "1" ]; then
        # Install ffnvcodec
        mkdir -p "${SOURCE_PREFIX}/nv-codec-headers"
        cd "${SOURCE_PREFIX}/nv-codec-headers"
        git clone --depth 1 --branch "${NVCODEC_HEADER_VERSION}" https://git.videolan.org/git/ffmpeg/nv-codec-headers.git ./

        make install

        rm -rf "${SOURCE_PREFIX}/nv-codec-headers"
    fi
EOF

# ffmpeg
# https://ffmpeg.org/download.html
ARG FFMPEG_REPOSITORY_URL=https://git.ffmpeg.org/ffmpeg.git
ARG FFMPEG_VERSION=n6.0.1
RUN <<EOF
    set -eux

    # NVIDIA video codec configuration
    # https://docs.nvidia.com/video-technologies/video-codec-sdk/12.1/ffmpeg-with-nvidia-gpu/index.html
    NVCODEC_OPTS=""
    if [ "${ENABLE_NVCODEC}" = "1" ]; then
        NVCODEC_OPTS="--enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64"
    fi

    mkdir -p ${SOURCE_PREFIX}/ffmpeg
    cd ${SOURCE_PREFIX}/ffmpeg
    git clone --depth 1 --branch "${FFMPEG_VERSION}" "${FFMPEG_REPOSITORY_URL}" ./

    ./configure \
        --prefix="${INSTALL_PREFIX}" \
        --pkg-config-flags="--static" \
        --extra-libs="-lpthread -lm" \
        --ld="g++" \
        --enable-gpl \
        --enable-gnutls \
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
        --enable-libsvtav1 \
        --enable-libdav1d \
        --enable-libvmaf \
        --enable-nonfree ${NVCODEC_OPTS}

    make -j$(nproc)
    make install

    rm -rf ${SOURCE_PREFIX}/ffmpeg
EOF

ENTRYPOINT [ "ffmpeg" ]
CMD [ "--help" ]
