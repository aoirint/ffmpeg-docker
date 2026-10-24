#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 IMAGE" >&2
  exit 2
fi

image=$1
network="ffmpeg-rtmp-test-$$"
listener="ffmpeg-rtmp-listener-$$"
secret_volume="ffmpeg-rtmp-secret-$$"
sink_one="ffmpeg-rtmp-sink-one-$$"
sink_two="ffmpeg-rtmp-sink-two-$$"
listener_log=$(mktemp)
publisher_log=$(mktemp)

cleanup() {
  docker container rm --force "${listener}" "${sink_one}" "${sink_two}" >/dev/null 2>&1 || true
  docker network rm "${network}" >/dev/null 2>&1 || true
  docker volume rm "${secret_volume}" >/dev/null 2>&1 || true
  rm -f -- "${listener_log}" "${publisher_log}"
}
trap cleanup EXIT

docker network create --internal "${network}" >/dev/null
docker volume create "${secret_volume}" >/dev/null

# A Docker volume preserves mode 600 and UID 1000 on Linux and Docker Desktop.
write_stream_file() {
  printf '%s' "$1" | docker run --rm -i --network none \
    --mount "type=volume,src=${secret_volume},dst=/test-secret" \
    --entrypoint sh "${image}" -c \
    'umask 077; cat >/test-secret/stream; chown 1000:1000 /test-secret/stream'
}

start_listener() {
  local outputs=${1:-'[f=flv:flvflags=no_duration_filesize]/tmp/first.flv|[f=flv:flvflags=no_duration_filesize]/tmp/second.flv'}
  local duration=${2:-1}
  docker container rm "${listener}" >/dev/null 2>&1 || true
  docker run --detach --name "${listener}" --network "${network}" \
    --user 1000:1000 --init --security-opt no-new-privileges:true --cap-drop ALL \
    --mount "type=volume,src=${secret_volume},dst=/run/secrets,readonly" \
    "${image}" -nostdin -loglevel warning \
    -listen 1 -rtmp_strict_paths 1 \
    -rtmp_strict_stream_file /run/secrets/stream \
    -analyzeduration 100000 -probesize 32768 -i rtmp://0.0.0.0:1935/live/placeholder \
    -t "${duration}" -map 0 -c copy -f tee -use_fifo 1 \
    -fifo_options 'drop_pkts_on_overflow=1:attempt_recovery=1:recovery_wait_time=1:recover_any_error=1:restart_with_keyframe=1' \
    "${outputs}" >/dev/null
  sleep 1
  if docker inspect "${listener}" --format '{{json .Config.Cmd}}' | grep -Fq stream-secret-value; then
    echo "Expected stream name leaked into listener arguments" >&2
    exit 1
  fi
}

publish_test_source() {
  local app=$1
  local stream=$2
  local duration=${3:-0.8}
  docker run --rm --network "${network}" --user 1000:1000 \
    --security-opt no-new-privileges:true --cap-drop ALL "${image}" \
    -nostdin -loglevel error -re -f lavfi -i testsrc2=size=64x64:rate=10 \
    -f lavfi -i sine=frequency=1000:sample_rate=44100 \
    -t "${duration}" -c:a aac -c:v libx264 -preset ultrafast -tune zerolatency -g 10 -f flv \
    "rtmp://${listener}:1935/${app}/${stream}"
}

assert_rejected() {
  local app=$1
  local stream=$2
  local expected_log=$3
  start_listener
  if publish_test_source "${app}" "${stream}" >"${publisher_log}" 2>&1; then
    echo "Invalid RTMP input was accepted" >&2
    exit 1
  fi
  test "$(timeout 20s docker wait "${listener}")" != 0
  docker logs "${listener}" >"${listener_log}" 2>&1
  grep -Fq "${expected_log}" "${listener_log}"
  if grep -Eq 'wrong-stream-value|stream-secret-value' "${listener_log}"; then
    echo "Stream name leaked into listener logs" >&2
    exit 1
  fi
  docker container rm "${listener}" >/dev/null
}

write_stream_file $'stream-secret-value\r\n'
docker run --rm --network none --user 1000:1000 \
  --mount "type=volume,src=${secret_volume},dst=/run/secrets,readonly" \
  --entrypoint sh "${image}" -ec '
    test "$(stat -c "%u:%g %a" /run/secrets/stream)" = "1000:1000 600"
    test -r /run/secrets/stream
    test ! -w /run/secrets/stream
  '
assert_rejected live wrong-stream-value 'Unexpected stream.'
assert_rejected wrong-app stream-secret-value "App field don't match up"

write_stream_file ''
assert_rejected live stream-secret-value 'must contain one non-empty stream name'

write_stream_file $'stream-secret-value\r\n'
start_listener
publish_test_source live stream-secret-value >"${publisher_log}" 2>&1
test "$(timeout 20s docker wait "${listener}")" = 0
packet_count() {
  docker cp "$1:$2" - | tar -xOf - | \
    docker run --rm -i --network none --entrypoint ffprobe "${image}" \
      -v error -count_packets -select_streams v:0 \
      -show_entries stream=nb_read_packets -of csv=p=0 -i pipe:0
}
for output in first second; do
  test "$(packet_count "${listener}" "/tmp/${output}.flv")" -gt 0
done
docker container rm "${listener}" >/dev/null

start_sink() {
  docker run --detach --name "$1" --network "${network}" --user 1000:1000 \
    --security-opt no-new-privileges:true --cap-drop ALL "${image}" \
    -nostdin -v error -listen 1 -analyzeduration 100000 -probesize 32768 \
    -i rtmp://0.0.0.0:1935/live/test-output \
    -map 0 -c copy -flush_packets 1 -f flv /tmp/received.flv >/dev/null
}
start_sink "${sink_one}"
start_sink "${sink_two}"
start_listener "[f=flv]rtmp://${sink_one}:1935/live/test-output|[f=flv]rtmp://${sink_two}:1935/live/test-output" 12
publish_test_source live stream-secret-value 12 >"${publisher_log}" 2>&1 &
publisher_pid=$!
# Observe media output before injecting failure; do not probe a listener port.
for _ in {1..100}; do
  if docker exec "${sink_one}" test -s /tmp/received.flv; then
    break
  fi
  sleep 0.1
done
docker exec "${sink_one}" test -s /tmp/received.flv
sleep 2
docker container rm --force "${sink_two}" >/dev/null
start_sink "${sink_two}"
wait "${publisher_pid}"
test "$(timeout 20s docker wait "${listener}")" = 0
test "$(timeout 20s docker wait "${sink_one}")" = 0
test "$(timeout 20s docker wait "${sink_two}")" = 0
first_packets=$(packet_count "${sink_one}" /tmp/received.flv)
recovered_packets=$(packet_count "${sink_two}" /tmp/received.flv)
test "${recovered_packets}" -gt 0
test "${first_packets}" -gt "${recovered_packets}"

echo "RTMP strict-path, non-root secret, tee/fifo and output recovery smoke test passed"
