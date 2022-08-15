# ffmpeg-docker
最新のffmpegを使うためのDockerfile

- <https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu>

|tag|description|
|:--|:--|
|`ffmpeg`|(same as ffmpeg:ubuntu)|
|`ffmpeg:ubuntu-*`|通常版|
|`ffmpeg:nvidia-*`|NVIDIA GPU ハードウェアエンコード対応版（NVIDIAドライバ510.x以降）|

## 用例

### 通常版

```shell
docker pull aoirint/ffmpeg:ubuntu-latest

docker run --rm aoirint/ffmpeg:ubuntu-latest --help
docker run --rm aoirint/ffmpeg:ubuntu-latest --formats
docker run --rm aoirint/ffmpeg:ubuntu-latest --encoders
docker run --rm aoirint/ffmpeg:ubuntu-latest --decoders
```

### NVIDIA GPU ハードウェアエンコード対応版

```shell
docker pull aoirint/ffmpeg:nvidia-latest

docker run --rm aoirint/ffmpeg:nvidia-latest --help
docker run --rm aoirint/ffmpeg:nvidia-latest --formats
docker run --rm aoirint/ffmpeg:nvidia-latest --encoders
docker run --rm aoirint/ffmpeg:nvidia-latest --decoders
```
