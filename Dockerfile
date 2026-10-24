# syntax=docker/dockerfile:1.19.0@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6
ARG BASE_IMAGE=ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea
FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND=noninteractive

ARG SOURCE_PREFIX=/ffmpeg_sources
ARG INSTALL_PREFIX=/usr/local

# Keep APT inputs older than seven days; review the snapshot before advancing it.
ARG UBUNTU_SNAPSHOT=20261016T000000Z
RUN <<EOF
    set -eux
    sed -i -E "s#http://(archive|security).ubuntu.com/ubuntu/?#http://snapshot.ubuntu.com/ubuntu/${UBUNTU_SNAPSHOT}/#g" /etc/apt/sources.list.d/ubuntu.sources
    # Keep CUDA libraries at the reviewed base-image versions.
    rm -f /etc/apt/sources.list.d/cuda*.list
    printf 'Acquire::Check-Valid-Until "false";\n' >/etc/apt/apt.conf.d/99snapshot
EOF

# Maintainer-approved cooldown exception, 2026-10-24: USN-8944-1 CA distrust.
# SHA-256 is from the Ubuntu noble-security package index of 2026-10-23.
ADD --checksum=sha256:8a0a754aaafed72cc8efb8c1731808133284a84fbfc76a4fcc73fce9e01b4187 https://snapshot.ubuntu.com/ubuntu/20261023T000000Z/pool/main/c/ca-certificates/ca-certificates_20260816ubuntu0.24.04.1_all.deb /tmp/ca-certificates.deb

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# dependencies
RUN <<EOF
    set -eux
    # The minimal base has no CA store; bootstrap HTTPS from the reviewed package.
    dpkg-deb -x /tmp/ca-certificates.deb /tmp/ca-bootstrap
    mkdir -p /etc/ssl/certs
    cat /tmp/ca-bootstrap/usr/share/ca-certificates/mozilla/*.crt >/etc/ssl/certs/ca-certificates.crt
    rm -rf /tmp/ca-bootstrap
    apt-get update
    apt-get -y upgrade
    apt-get -y install \
        autoconf \
        automake \
        build-essential \
        cmake \
        git \
        libfontconfig-dev \
        libfribidi-dev \
        libharfbuzz-dev \
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
        meson \
        ninja-build
    dpkg -i /tmp/ca-certificates.deb
    rm /tmp/ca-certificates.deb
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
ARG LIBVPX_VERSION=6df3ec34557879fff673706f4a1d9fbd0f3a6f0e
# libvpx v1.17.0
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libvpx
    cd ${SOURCE_PREFIX}/libvpx
    git init
    git remote add origin https://chromium.googlesource.com/webm/libvpx.git
    git fetch --depth 1 origin "${LIBVPX_VERSION}"
    git checkout --detach FETCH_HEAD
    ./configure --prefix="${INSTALL_PREFIX}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm
    make -j$(nproc)
    make install
    install -D -m 0644 LICENSE "${INSTALL_PREFIX}/share/licenses/libvpx/LICENSE"
    install -D -m 0644 PATENTS "${INSTALL_PREFIX}/share/licenses/libvpx/PATENTS"
    rm -rf ${SOURCE_PREFIX}/libvpx
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
ARG AOM_VERSION=de4c1d1edc49723a78954d30a83690aa1937422f
# libaom v3.15.0
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libaom
    cd ${SOURCE_PREFIX}/libaom
    git init
    git remote add origin https://aomedia.googlesource.com/aom.git
    git fetch --depth 1 origin "${AOM_VERSION}"
    git checkout --detach FETCH_HEAD
    mkdir aom_build
    cd aom_build
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off -DENABLE_TESTS=off -DENABLE_NASM=on ../
    make -j$(nproc)
    make install
    install -D -m 0644 ../LICENSE "${INSTALL_PREFIX}/share/licenses/libaom/LICENSE"
    install -D -m 0644 ../PATENTS "${INSTALL_PREFIX}/share/licenses/libaom/PATENTS"
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

# libass 0.17.5 fixes GHSA-pjjp-65r7-ppgm and GHSA-5gf7-wjfm-vmvm.
ARG LIBASS_VERSION=4a05d8127f525943ebf45fdc6497c9e665947f0d
RUN <<EOF
    set -eux
    mkdir -p ${SOURCE_PREFIX}/libass
    cd ${SOURCE_PREFIX}/libass
    git init
    git remote add origin https://github.com/libass/libass.git
    git fetch --depth 1 origin "${LIBASS_VERSION}"
    git checkout --detach FETCH_HEAD
    ./autogen.sh
    ./configure --prefix="${INSTALL_PREFIX}" --disable-shared
    make -j$(nproc)
    make install
    install -D -m 0644 COPYING "${INSTALL_PREFIX}/share/licenses/libass/COPYING"
    rm -rf ${SOURCE_PREFIX}/libass
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
        git clone --depth 1 --branch "${NVCODEC_HEADER_VERSION}" https://github.com/FFmpeg/nv-codec-headers.git ./

        make install

        rm -rf "${SOURCE_PREFIX}/nv-codec-headers"
    fi
EOF

# ffmpeg
# https://ffmpeg.org/download.html
ARG FFMPEG_REPOSITORY_URL=https://github.com/FFmpeg/FFmpeg.git
ARG FFMPEG_VERSION=946fcce07b6dcd0331c8cc609192aeff5e1924f8
# upstream n9.0.2
RUN <<EOF
    set -eux

    # NVIDIA video codec configuration
    # https://docs.nvidia.com/video-technologies/video-codec-sdk/12.1/ffmpeg-with-nvidia-gpu/index.html
    NVCODEC_OPTS=""
    if [ "${ENABLE_NVCODEC}" = "1" ]; then
        NVCODEC_OPTS="--extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64"
    fi

    mkdir -p ${SOURCE_PREFIX}/ffmpeg
    cd ${SOURCE_PREFIX}/ffmpeg
    git init
    git remote add origin "${FFMPEG_REPOSITORY_URL}"
    git fetch --depth 1 origin "${FFMPEG_VERSION}"
    git checkout --detach FETCH_HEAD

    ./configure \
        --prefix="${INSTALL_PREFIX}" \
        --pkg-config-flags="--static" \
        --extra-libs="-lpthread -lm" \
        --ld="g++" \
        --enable-gpl \
        --enable-version3 \
        --enable-gnutls \
        --enable-libaom \
        --enable-libass \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libsvtav1 \
        --enable-libdav1d \
        --enable-libvmaf ${NVCODEC_OPTS}

    make -j$(nproc)
    make install

    install -D -m 0644 LICENSE.md "${INSTALL_PREFIX}/share/licenses/ffmpeg/LICENSE.md"
    install -D -m 0644 COPYING.GPLv3 "${INSTALL_PREFIX}/share/licenses/ffmpeg/COPYING.GPLv3"

    rm -rf ${SOURCE_PREFIX}/ffmpeg
EOF

ENTRYPOINT [ "ffmpeg" ]
CMD [ "--help" ]
