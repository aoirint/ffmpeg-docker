.PHONY: build
build:
	docker build -t ffmpeg .

.PHONY: build-nvidia
build-nvidia:
	docker build -t ffmpeg:nvidia \
		--build-arg "BASE_IMAGE=nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04@sha256:24c8e3581ea6330038b0d374920721983312627f8adbfcf390bdb4b399d280ed" \
		--build-arg "ENABLE_NVCODEC=1" .
