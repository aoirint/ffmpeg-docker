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
stream_file=$(mktemp)

printf '%s\n' "stream-secret-value" >"${stream_file}"
chmod 644 "${stream_file}"

cleanup() {
  docker container rm --force "${listener}" >/dev/null 2>&1 || true
  docker network rm "${network}" >/dev/null 2>&1 || true
  find "${listener_log}" "${publisher_log}" "${stream_file}" -delete
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
    --mount "type=bind,src=${stream_file},dst=/run/secrets/rtmp_stream,readonly" \
    "${image}" \
    -nostdin -loglevel warning \
    -listen 1 -rtmp_strict_paths 1 \
    -rtmp_strict_stream_file /run/secrets/rtmp_stream \
    -i "rtmp://0.0.0.0:1935/live/placeholder" \
    -t "${duration}" -map 0 -c copy -f null - >/dev/null

  sleep 1
  if docker inspect "${listener}" --format '{{json .Config.Cmd}}' | grep -Fq "stream-secret-value"; then
    echo "The expected stream name was exposed in the listener command" >&2
    exit 1
  fi
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
if publish_test_source wrong-stream-value 0.5 >"${publisher_log}" 2>&1; then
  echo "A mismatched RTMP stream path was accepted" >&2
  exit 1
fi
docker wait "${listener}" >/dev/null
docker logs "${listener}" >"${listener_log}" 2>&1
grep -Fq "Unexpected stream." "${listener_log}"
if grep -Fq "wrong-stream-value" "${listener_log}" || grep -Fq "stream-secret-value" "${listener_log}"; then
  echo "A stream name was exposed in the listener log" >&2
  exit 1
fi
docker container rm "${listener}" >/dev/null

start_listener 1
publish_test_source stream-secret-value 0.8 >"${publisher_log}" 2>&1
test "$(docker wait "${listener}")" = "0"
docker container rm "${listener}" >/dev/null

echo "RTMP strict-path smoke test passed"
