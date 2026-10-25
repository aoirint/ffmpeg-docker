# syntax=docker/dockerfile:1.19.0@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6
ARG BASE_IMAGE=ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea
ARG RUNTIME_IMAGE=ubuntu:24.04@sha256:561618e2c15bf2397621dd04f96926663a3b5616c189cf7e38db7e82f5c538ea
FROM $BASE_IMAGE AS build-base

ARG DEBIAN_FRONTEND=noninteractive

ARG SOURCE_PREFIX=/ffmpeg_sources
ARG INSTALL_PREFIX=/usr/local
# Bound each compiler pool because independent library stages run concurrently.
ARG BUILD_JOBS=4

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
        libx265-dev \
        libnuma-dev \
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

FROM build-base AS nasm
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    rm -rf ${SOURCE_PREFIX}/nasm
EOF

FROM build-base AS library-base
COPY --from=nasm /out/usr/local/ /usr/local/

FROM library-base AS x264
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 COPYING "/out${INSTALL_PREFIX}/share/licenses/x264/COPYING"
    rm -rf ${SOURCE_PREFIX}/libx264
EOF

FROM library-base AS vpx
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 LICENSE "/out${INSTALL_PREFIX}/share/licenses/libvpx/LICENSE"
    install -D -m 0644 PATENTS "/out${INSTALL_PREFIX}/share/licenses/libvpx/PATENTS"
    rm -rf ${SOURCE_PREFIX}/libvpx
EOF

FROM library-base AS lame
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 COPYING "/out${INSTALL_PREFIX}/share/licenses/lame/COPYING"
    rm -rf ${SOURCE_PREFIX}/libmp3lame
EOF

FROM library-base AS opus
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 COPYING "/out${INSTALL_PREFIX}/share/licenses/opus/COPYING"
    rm -rf ${SOURCE_PREFIX}/libopus
EOF

FROM library-base AS aom
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 ../LICENSE "/out${INSTALL_PREFIX}/share/licenses/libaom/LICENSE"
    install -D -m 0644 ../PATENTS "/out${INSTALL_PREFIX}/share/licenses/libaom/PATENTS"
    rm -rf ${SOURCE_PREFIX}/libaom
EOF

FROM library-base AS svtav1
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 ../LICENSE.md "/out${INSTALL_PREFIX}/share/licenses/svtav1/LICENSE.md"
    rm -rf ${SOURCE_PREFIX}/SVT-AV1
EOF

FROM library-base AS ass
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
    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install
    install -D -m 0644 COPYING "/out${INSTALL_PREFIX}/share/licenses/libass/COPYING"
    rm -rf ${SOURCE_PREFIX}/libass
EOF

FROM library-base AS dav1d
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
    ninja -j "${BUILD_JOBS}"
    DESTDIR=/out ninja install
    install -D -m 0644 ../COPYING "/out${INSTALL_PREFIX}/share/licenses/dav1d/COPYING"
    rm -rf ${SOURCE_PREFIX}/dav1d
EOF

FROM library-base AS vmaf
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
    ninja -j "${BUILD_JOBS}"
    DESTDIR=/out ninja install
    install -D -m 0644 ../../LICENSE "/out${INSTALL_PREFIX}/share/licenses/vmaf/LICENSE"
    rm -rf ${SOURCE_PREFIX}/vmaf
EOF

FROM build-base AS nvcodec
# NVIDIA video codec
# https://git.videolan.org/?p=ffmpeg/nv-codec-headers.git
ARG ENABLE_NVCODEC=0
ARG NVCODEC_HEADER_VERSION=n12.2.72.0
RUN <<EOF
    set -eux

    mkdir -p /out/usr/local
    if [ "${ENABLE_NVCODEC}" = "1" ]; then
        # Install ffnvcodec
        mkdir -p "${SOURCE_PREFIX}/nv-codec-headers"
        cd "${SOURCE_PREFIX}/nv-codec-headers"
        git clone --depth 1 --branch "${NVCODEC_HEADER_VERSION}" https://github.com/FFmpeg/nv-codec-headers.git ./

        make DESTDIR=/out install
        # Upstream embeds its MIT notices in each header rather than a COPYING file.
        mkdir -p "/out${INSTALL_PREFIX}/share/licenses/nv-codec-headers"
        for header in include/ffnvcodec/*.h; do
            sed -n '1,/ \*\//p' "${header}" >"/out${INSTALL_PREFIX}/share/licenses/nv-codec-headers/$(basename "${header}").txt"
        done

        rm -rf "${SOURCE_PREFIX}/nv-codec-headers"
    fi
EOF

FROM library-base AS ffmpeg-build
COPY --from=x264 /out/usr/local/ /usr/local/
COPY --from=vpx /out/usr/local/ /usr/local/
COPY --from=lame /out/usr/local/ /usr/local/
COPY --from=opus /out/usr/local/ /usr/local/
COPY --from=aom /out/usr/local/ /usr/local/
COPY --from=svtav1 /out/usr/local/ /usr/local/
COPY --from=ass /out/usr/local/ /usr/local/
COPY --from=dav1d /out/usr/local/ /usr/local/
COPY --from=vmaf /out/usr/local/ /usr/local/
COPY --from=nvcodec /out/usr/local/ /usr/local/
ARG ENABLE_NVCODEC=0

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

    make -j"${BUILD_JOBS}"
    make DESTDIR=/out install

    install -D -m 0644 LICENSE.md "/out${INSTALL_PREFIX}/share/licenses/ffmpeg/LICENSE.md"
    install -D -m 0644 COPYING.GPLv3 "/out${INSTALL_PREFIX}/share/licenses/ffmpeg/COPYING.GPLv3"

    cp -a "${INSTALL_PREFIX}/share/licenses/." "/out${INSTALL_PREFIX}/share/licenses/"
    rm -rf ${SOURCE_PREFIX}/ffmpeg
EOF

FROM $RUNTIME_IMAGE AS runtime
ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_SNAPSHOT=20261016T000000Z
COPY --from=build-base /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
COPY --from=build-base /etc/apt/apt.conf.d/99snapshot /etc/apt/apt.conf.d/99snapshot
# Bootstrap HTTPS with the same reviewed CA package as the build foundation.
COPY --from=build-base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ADD --checksum=sha256:8a0a754aaafed72cc8efb8c1731808133284a84fbfc76a4fcc73fce9e01b4187 https://snapshot.ubuntu.com/ubuntu/20261023T000000Z/pool/main/c/ca-certificates/ca-certificates_20260816ubuntu0.24.04.1_all.deb /tmp/ca-certificates.deb
RUN <<EOF
    set -eux
    apt-get update
    apt-get -y upgrade
    apt-get install -y --no-install-recommends \
        ca-certificates \
        fonts-dejavu-core \
        libfontconfig1 \
        libfribidi0 \
        libharfbuzz0b \
        libfreetype6 \
        libgnutls30t64 \
        libunistring5 \
        libsdl2-2.0-0 \
        libsndio7.0 \
        libva2 \
        libva-drm2 \
        libva-x11-2 \
        libvdpau1 \
        va-driver-all \
        vdpau-driver-all \
        libvorbis0a \
        libvorbisenc2 \
        libxcb1 \
        libxcb-shm0 \
        libxcb-shape0 \
        libxcb-xfixes0 \
        libxv1 \
        libx265-199 \
        libnuma1 \
        libstdc++6 \
        openssl \
        zlib1g
    dpkg -i /tmp/ca-certificates.deb
    rm /tmp/ca-certificates.deb
    apt-get clean
    rm -rf /var/lib/apt/lists/*
EOF
COPY --from=ffmpeg-build /out/usr/local/bin/ /usr/local/bin/
COPY --from=x264 /out/usr/local/bin/ /usr/local/bin/
COPY --from=lame /out/usr/local/bin/ /usr/local/bin/
COPY --from=vmaf /out/usr/local/bin/ /usr/local/bin/
COPY --from=ffmpeg-build /out/usr/local/share/licenses/ /usr/local/share/licenses/

ENTRYPOINT [ "ffmpeg" ]
CMD [ "--help" ]
