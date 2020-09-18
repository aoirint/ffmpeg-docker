ARG BASE_IMAGE=ubuntu:bionic
FROM $BASE_IMAGE

# https://www.nasm.us/
ARG NASM_VERSION=2.14.02
# https://code.videolan.org/videolan/x264.git
ARG LIBX264_VERSION=db0d417728460c647ed4a847222a535b00d3dbcb
# https://bitbucket.org/multicoreware/x265_git.git
# ARG LIBX265_VERSION=a82c6c7a7d5f5ef836c82941788a37c6a443e0fe
# https://chromium.googlesource.com/webm/libvpx.git
ARG LIBVPX_VERSION=aea631263d38e45a7f119d39ccc3dc065db01f08
# https://github.com/mstorsjo/fdk-aac.git
ARG AAC_VERSION=3a831a5fbc990c83e9b5b804a082bb158364e793
# https://sourceforge.net/projects/lame/files/
ARG LAME_VERSION=3.100
# https://github.com/xiph/opus.git
ARG OPUS_VERSION=034c1b61a250457649d788bbf983b3f0fb63f02e
# https://aomedia.googlesource.com/aom.git
# use tag because commit id of the same commit on master branch quite frequently chnages
ARG AOM_VERSION=v2.0.0
# https://ffmpeg.org/download.html
ARG FFMPEG_VERSION=4.3.1

ARG SOURCE_PREFIX=/ffmpeg_sources
ARG INSTALL_PREFIX=/usr/local

# https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu
# dependencies
RUN apt-get update -qq && apt-get -y install \
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

# nasm
RUN mkdir -p ${SOURCE_PREFIX}/nasm \
  && cd ${SOURCE_PREFIX}/ \
  && wget -O nasm.tar.bz2 https://www.nasm.us/pub/nasm/releasebuilds/${NASM_VERSION}/nasm-${NASM_VERSION}.tar.bz2 \
  && tar xjvf ./nasm.tar.bz2 -C ./nasm --strip-components 1 \
  && cd ./nasm/ \
  && ./autogen.sh \
  && ./configure --prefix="${INSTALL_PREFIX}" \
  && make -j$(nproc) \
  && make install

# libx264
RUN mkdir -p ${SOURCE_PREFIX}/libx264 \
  && cd ${SOURCE_PREFIX}/libx264 \
  && git -C x264 pull 2> /dev/null \
  || git clone --depth 1 https://code.videolan.org/videolan/x264.git ./ \
  && git checkout ${LIBX264_VERSION} \
  && ./configure --prefix="${INSTALL_PREFIX}" --enable-static --enable-pic \
  && make -j$(nproc) \
  && make install

# libx265
RUN apt-get install -y libx265-dev libnuma-dev

# broken manual builds
# RUN mkdir -p ${SOURCE_PREFIX}/libx265 \
#   && cd ${SOURCE_PREFIX}/libx265 \
#   && apt-get install libnuma-dev \
#   && git -C x265_git pull 2> /dev/null \
#   || git clone --depth 1 https://bitbucket.org/multicoreware/x265_git.git ./ \
#   && git checkout ${LIBX265_VERSION} \
#   && cd ./build/linux \
#   && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off ../../source \
#   && make -j$(nproc) \
#   && make install


# libvpx
RUN mkdir -p ${SOURCE_PREFIX}/libvpx \
  && cd ${SOURCE_PREFIX}/libvpx \
  && git -C libvpx pull 2> /dev/null \
  || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git ./ \
  && git checkout ${LIBVPX_VERSION} \
  && ./configure --prefix="${INSTALL_PREFIX}" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm \
  && make -j$(nproc) \
  && make install

# libfdk-aac
RUN mkdir -p ${SOURCE_PREFIX}/libfdk-aac \
  && cd ${SOURCE_PREFIX}/libfdk-aac \
  && git -C fdk-aac pull 2> /dev/null \
  || git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git ./ \
  && git checkout ${AAC_VERSION} \
  && autoreconf -fiv \
  && ./configure --prefix="${INSTALL_PREFIX}" --disable-shared \
  && make -j$(nproc) \
  && make install

# libmp3lame
RUN mkdir -p ${SOURCE_PREFIX}/libmp3lame \
  && cd ${SOURCE_PREFIX}/ \
  && wget -O lame.tar.gz https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/lame-${LAME_VERSION}.tar.gz \
  && tar xzvf lame.tar.gz -C ./libmp3lame --strip-components 1 \
  && cd ./libmp3lame/ \
  && ./configure --prefix="${INSTALL_PREFIX}" --disable-shared --enable-nasm \
  && make -j$(nproc) \
  && make install

# libopus
RUN mkdir -p ${SOURCE_PREFIX}/libopus \
  && cd ${SOURCE_PREFIX}/libopus \
  && git -C opus pull 2> /dev/null \
  || git clone --depth 1 https://github.com/xiph/opus.git ./ \
  && git checkout ${OPUS_VERSION} \
  && ./autogen.sh \
  && ./configure --prefix="${INSTALL_PREFIX}" --disable-shared \
  && make -j$(nproc) \
  && make install

# libaom
RUN mkdir -p ${SOURCE_PREFIX}/libaom \
  && cd ${SOURCE_PREFIX}/libaom \
  && git -C aom pull 2> /dev/null \
  || git clone --depth 1 https://aomedia.googlesource.com/aom.git ./ \
  && git checkout ${AOM_VERSION} \
  && mkdir aom_build \
  && cd aom_build \
  && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" -DENABLE_SHARED=off -DENABLE_NASM=on ../ \
  && make -j$(nproc) \
  && make install

# ffmpeg
RUN mkdir -p ${SOURCE_PREFIX}/ffmpeg \
  && cd ${SOURCE_PREFIX}/ \
  && wget -O ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 \
  && tar xjvf ffmpeg.tar.bz2 -C ./ffmpeg --strip-components 1 \
  && cd ./ffmpeg/ \
  && ./configure \
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
    --enable-nonfree \
  && make -j$(nproc) \
  && make install

RUN apt-get clean \
  && rm -rf ${SOURCE_PREFIX}

ENTRYPOINT [ "ffmpeg" ]
CMD [ "--help" ]
