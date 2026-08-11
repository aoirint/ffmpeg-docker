#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 IMAGE" >&2
  exit 2
fi

image=$1
network="ffmpeg-rtmp-test-$$"
listener="ffmpeg-rtmp-listener-$$"
listener_log=$(mktemp)
publisher_log=$(mktemp)

cleanup() {
  docker container rm --force "${listener}" >/dev/null 2>&1 || true
  docker network rm "${network}" >/dev/null 2>&1 || true
  find "${listener_log}" "${publisher_log}" -delete
}
trap cleanup EXIT

docker network create "${network}" >/dev/null

start_listener() {
  local duration=$1

  docker container rm "${listener}" >/dev/null 2>&1 || true
  docker run --detach \
    --name "${listener}" \
    --network "${network}" \
    --init \
    --security-opt no-new-privileges:true \
    --cap-drop ALL \
    "${image}" \
    -nostdin -loglevel warning \
    -listen 1 -rtmp_strict_paths 1 \
    -i "rtmp://0.0.0.0:1935/live/expected" \
    -t "${duration}" -map 0 -c copy -f null - >/dev/null

  sleep 1
}

publish_test_source() {
  local stream=$1
  local duration=$2

  docker run --rm \
    --network "${network}" \
    --security-opt no-new-privileges:true \
    --cap-drop ALL \
    "${image}" \
    -nostdin -loglevel error \
    -f lavfi -i testsrc2=size=64x64:rate=10 \
    -t "${duration}" -c:v libx264 -preset ultrafast -f flv \
    "rtmp://${listener}:1935/live/${stream}"
}

start_listener 1
if publish_test_source wrong 0.5 >"${publisher_log}" 2>&1; then
  echo "A mismatched RTMP stream path was accepted" >&2
  exit 1
fi
docker logs "${listener}" >"${listener_log}" 2>&1 || true
grep -Fq "Unexpected stream" "${listener_log}"
docker wait "${listener}" >/dev/null
docker container rm "${listener}" >/dev/null

start_listener 1
publish_test_source expected 0.8 >"${publisher_log}" 2>&1
test "$(docker wait "${listener}")" = "0"
docker container rm "${listener}" >/dev/null

echo "RTMP strict-path smoke test passed"
