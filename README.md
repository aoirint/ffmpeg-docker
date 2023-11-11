# ffmpeg-docker
最新のffmpegを使うためのDockerイメージ

- <https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu>

|tag|description|
|:--|:--|
|`ffmpeg`|(same as `ffmpeg:ubuntu`)|
|`ffmpeg:ubuntu-*`|通常版|
|`ffmpeg:nvidia-*`|~~NVIDIA GPU ハードウェアコーデック対応版（NVIDIAドライバ525.x以降）~~|
|`ffmpeg:ubuntu-aoirint-*`|aoirint Fork版|

- Docker Hub: <https://hub.docker.com/r/aoirint/ffmpeg>

## 用例

### 通常版

```shell
docker pull aoirint/ffmpeg:ubuntu-latest

docker run --rm aoirint/ffmpeg:ubuntu-latest -help
docker run --rm aoirint/ffmpeg:ubuntu-latest -formats
docker run --rm aoirint/ffmpeg:ubuntu-latest -encoders
docker run --rm aoirint/ffmpeg:ubuntu-latest -decoders
```

### ~~NVIDIA GPU ハードウェアコーデック対応版~~

現在、ハードウェアコーデックは動作しません。今後修正予定です。

- https://github.com/aoirint/ffmpeg-docker/issues/28

```shell
docker pull aoirint/ffmpeg:nvidia-latest

docker run --rm --gpus all aoirint/ffmpeg:nvidia-latest -help
docker run --rm --gpus all aoirint/ffmpeg:nvidia-latest -formats
docker run --rm --gpus all aoirint/ffmpeg:nvidia-latest -encoders
docker run --rm --gpus all aoirint/ffmpeg:nvidia-latest -decoders
```

### aoirint Fork版

[aoirint/FFmpeg](https://github.com/aoirint/FFmpeg)でメンテナンスしているFork版。

```shell
docker pull aoirint/ffmpeg:ubuntu-aoirint-latest

docker run --rm aoirint/ffmpeg:ubuntu-aoirint-latest -help
docker run --rm aoirint/ffmpeg:ubuntu-aoirint-latest -formats
docker run --rm aoirint/ffmpeg:ubuntu-aoirint-latest -encoders
docker run --rm aoirint/ffmpeg:ubuntu-aoirint-latest -decoders
```
