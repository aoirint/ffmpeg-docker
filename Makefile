.PHONY: build
build:
	docker build -t ffmpeg .

.PHONY: build-nvidia
build-nvidia:
	docker build -t ffmpeg:nvidia \
		--build-arg "BASE_IMAGE=nvcr.io/nvidia/cuda:13.4.3-cudnn-devel-ubuntu26.04@sha256:a34cd707296198f7bf581ab8da0a977e2d6cea912ba081cf872c6742e3ade503" \
		--build-arg "ENABLE_NVCODEC=1" .
