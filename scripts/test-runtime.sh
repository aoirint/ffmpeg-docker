#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 IMAGE" >&2
  exit 2
fi

docker run --rm --network none --read-only --user 1000:1000 --cap-drop ALL \
  --security-opt no-new-privileges:true --entrypoint sh "$1" -c '
    set -eu
    for program in ffmpeg ffprobe ffplay x264 lame vmaf; do
      command -v "${program}"
      links=$(ldd "/usr/local/bin/${program}")
      printf "%s\n" "${links}"
      if printf "%s\n" "${links}" | grep -F "not found"; then
        exit 1
      fi
    done
    for program in ffmpeg ffprobe ffplay; do
      "${program}" -version >/dev/null
    done
    for tool in gcc g++ make cmake meson ninja nasm yasm git nvcc; do
      if command -v "${tool}"; then
        echo "Build tool retained in runtime: ${tool}" >&2
        exit 1
      fi
    done
    test ! -d /ffmpeg_sources
    test -z "$(find /usr/local/include -mindepth 1 -print -quit)"
    test ! -d /usr/local/lib/pkgconfig
    test -z "$(find /usr/local -name "*.a" -print -quit)"
    test -s /usr/share/doc/libx265-199/copyright
    for file in ffmpeg/LICENSE.md ffmpeg/COPYING.GPLv3 x264/COPYING \
      libvpx/LICENSE libvpx/PATENTS lame/COPYING opus/COPYING \
      libaom/LICENSE libaom/PATENTS svtav1/LICENSE.md libass/COPYING \
      dav1d/COPYING vmaf/LICENSE; do
      test -s "/usr/local/share/licenses/${file}"
    done
    test -s /etc/ssl/certs/ca-certificates.crt
    license=$(ffmpeg -L 2>&1)
    printf "%s\n" "${license}" | grep -F "GNU General Public License"
    printf "%s\n" "${license}" | grep -F "version 3 of the License"
    if printf "%s\n" "${license}" | grep -Ei "nonfree|not legally redistributable"; then
      exit 1
    fi
    ffprobe -v error -f lavfi -i testsrc2=size=64x64:rate=1 \
      -show_entries stream=width,height -of csv=p=0 | grep -Fx "64,64"
  '

echo "Runtime linkage, packaging, notices and non-root execution passed"
