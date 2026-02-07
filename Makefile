.PHONY: build
build:
	docker build -t ffmpeg .

.PHONY: build-nvidia
build-nvidia:
	docker build -t ffmpeg:nvidia \
		--build-arg "BASE_IMAGE=nvcr.io/nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04" \
		--build-arg "ENABLE_NVCODEC=1" .
