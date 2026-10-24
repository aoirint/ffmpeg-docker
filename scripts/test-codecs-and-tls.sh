#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 IMAGE" >&2
  exit 2
fi

image=$1
network="ffmpeg-tls-test-$$"
server="ffmpeg-tls-server-$$"
fixtures="ffmpeg-tls-fixtures-$$"
client_log=$(mktemp)
cleanup() {
  docker container rm --force "${server}" >/dev/null 2>&1 || true
  docker network rm "${network}" >/dev/null 2>&1 || true
  docker volume rm "${fixtures}" >/dev/null 2>&1 || true
  rm -f -- "${client_log}"
}
trap cleanup EXIT

docker network create --internal "${network}" >/dev/null
docker volume create "${fixtures}" >/dev/null
docker run --rm --network none --mount "type=volume,src=${fixtures},dst=/fixtures" \
  --entrypoint sh "${image}" -c '
    set -eu
    openssl req -x509 -newkey rsa:2048 -noenc -days 1 \
      -subj /CN=ffmpeg-tls.test -addext subjectAltName=DNS:ffmpeg-tls.test \
      -keyout /fixtures/server.key -out /fixtures/ca.pem >/dev/null 2>&1
    printf "%s\n" "[Script Info]" "ScriptType: v4.00+" \
      "[V4+ Styles]" "Format: Name, Fontname, Fontsize, PrimaryColour" \
      "Style: Default,DejaVu Sans,12,&H00FFFFFF" "[Events]" \
      "Format: Layer, Start, End, Style, Text" \
      "Dialogue: 0,0:00:00.00,0:00:01.00,Default,Test" >/fixtures/sample.ass
  '

for codec in libvpx-vp9 libaom-av1; do
  docker run --rm --network none --user 1000:1000 --cap-drop ALL \
    --security-opt no-new-privileges:true "${image}" \
    -nostdin -v error -f lavfi -i testsrc2=size=64x64:rate=1 \
    -frames:v 1 -c:v "${codec}" -cpu-used 8 -f null -
done
docker run --rm --network none --user 1000:1000 --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --mount "type=volume,src=${fixtures},dst=/fixtures,readonly" "${image}" \
  -nostdin -v error -f lavfi -i color=size=64x64:rate=1 \
  -vf ass=/fixtures/sample.ass -frames:v 1 -f null -

docker run --detach --name "${server}" --network "${network}" \
  --network-alias ffmpeg-tls.test --network-alias wrong.test \
  --mount "type=volume,src=${fixtures},dst=/fixtures,readonly" \
  --entrypoint openssl "${image}" s_server -quiet -accept 24443 \
  -cert /fixtures/ca.pem -key /fixtures/server.key >/dev/null
sleep 1
test "$(docker inspect --format '{{.State.Running}}' "${server}")" = true

send_tls() {
  local hostname=$1
  shift
  timeout 20s docker run --rm --network "${network}" --user 1000:1000 \
    --cap-drop ALL --security-opt no-new-privileges:true \
    --mount "type=volume,src=${fixtures},dst=/fixtures,readonly" "${image}" \
    -nostdin -v error -f lavfi -i testsrc2=size=64x64:rate=1 \
    -frames:v 1 -c:v libx264 -f mpegts "$@" "tls://${hostname}:24443"
}

send_tls ffmpeg-tls.test -ca_file /fixtures/ca.pem >"${client_log}" 2>&1
if send_tls ffmpeg-tls.test >"${client_log}" 2>&1; then
  echo "Untrusted TLS certificate was accepted" >&2
  exit 1
fi
grep -Eiq 'certificate|verify' "${client_log}"
if send_tls wrong.test -ca_file /fixtures/ca.pem >"${client_log}" 2>&1; then
  echo "TLS hostname mismatch was accepted" >&2
  exit 1
fi
grep -Eiq 'certificate|hostname' "${client_log}"

echo "Updated codecs, libass and TLS trust/hostname smoke test passed"
