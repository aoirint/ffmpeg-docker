#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 IMAGE" >&2
  exit 2
fi

# Driver libraries are injected by the host; neither CUDA nor cuDNN is bundled.
docker run --rm --network none --gpus 'all,"capabilities=compute,video"' \
  --read-only --tmpfs /tmp:rw,nosuid,size=64m --user 1000:1000 --cap-drop ALL \
  --security-opt no-new-privileges:true --entrypoint sh "$1" -c '
    set -eu
    test -s /usr/local/share/licenses/nv-codec-headers/nvEncodeAPI.h.txt
    for codec in h264 hevc av1; do
      ffmpeg -nostdin -v error -f lavfi -i testsrc2=size=640x360:rate=5 \
        -frames:v 5 -pix_fmt yuv420p -c:v "${codec}_nvenc" "/tmp/${codec}.mkv"
      ffmpeg -nostdin -v error -hwaccel cuda -hwaccel_output_format cuda \
        -i "/tmp/${codec}.mkv" -vf hwdownload,format=nv12 -f null -
      ffmpeg -nostdin -v error -c:v "${codec}_cuvid" \
        -i "/tmp/${codec}.mkv" -f null -
      echo "${codec}: NVENC encode, CUDA and CUVID decode passed"
    done
  '
