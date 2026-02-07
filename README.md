# ffmpeg-docker

最新のFFmpegを使うためのDockerイメージ

- <https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu>

|バリアント|イメージ|説明|
|:--|:--|:--|
|latest|`aoirint/ffmpeg:latest`|`ffmpeg:ubuntu` と同じ|
|latest|`aoirint/ffmpeg:v<version>`|`ffmpeg:v<version>-ubuntu` と同じ|
|latest|`aoirint/ffmpeg:edge`|`ffmpeg:ubuntu-edge` と同じ|
|ubuntu|`aoirint/ffmpeg:ubuntu`|ubuntu版の最新リリース（プレリリース除く）|
|ubuntu|`aoirint/ffmpeg:v<version>-ubuntu`|ubuntu版の指定バージョン|
|ubuntu|`aoirint/ffmpeg:ubuntu-edge`|ubuntu版のmainブランチ最新版|
|nvidia|`aoirint/ffmpeg:nvidia`|NVIDIA GPU ハードウェアコーデック対応版の最新リリース（プレリリース除く）|
|nvidia|`aoirint/ffmpeg:v<version>-nvidia`|NVIDIA GPU ハードウェアコーデック対応版の指定バージョン|
|nvidia|`aoirint/ffmpeg:nvidia-edge`|NVIDIA GPU ハードウェアコーデック対応版のmainブランチ最新版|
|ubuntu-aoirint|`aoirint/ffmpeg:ubuntu-aoirint`|aoirint Fork版の最新リリース（プレリリース除く）|
|ubuntu-aoirint|`aoirint/ffmpeg:v<version>-ubuntu-aoirint`|aoirint Fork版の指定バージョン|
|ubuntu-aoirint|`aoirint/ffmpeg:ubuntu-aoirint-edge`|aoirint Fork版のmainブランチ最新版|

- Docker Hub: <https://hub.docker.com/r/aoirint/ffmpeg>

## リリース手順

1. GitHub Release を作成する（タグは `v<version>` 形式）
	- 例: `v0.4.0`
2. プレリリースの場合は「Pre-release」にチェックを付ける
3. 公開するとタグ付きイメージが作成される（`latest` はプレリリースを除外）

## 用例

### 通常版

```shell
docker pull aoirint/ffmpeg:ubuntu

docker run --rm aoirint/ffmpeg:ubuntu -help
docker run --rm aoirint/ffmpeg:ubuntu -formats
docker run --rm aoirint/ffmpeg:ubuntu -encoders
docker run --rm aoirint/ffmpeg:ubuntu -decoders
```

### NVIDIA GPU ハードウェアコーデック対応版

```shell
docker pull aoirint/ffmpeg:nvidia

docker run --rm --gpus all,capabilities=video aoirint/ffmpeg:nvidia -help
docker run --rm --gpus all,capabilities=video aoirint/ffmpeg:nvidia -formats
docker run --rm --gpus all,capabilities=video aoirint/ffmpeg:nvidia -encoders
docker run --rm --gpus all,capabilities=video aoirint/ffmpeg:nvidia -decoders
```

### aoirint Fork版

[aoirint/FFmpeg](https://github.com/aoirint/FFmpeg)でメンテナンスしているFork版。

```shell
docker pull aoirint/ffmpeg:ubuntu-aoirint

docker run --rm aoirint/ffmpeg:ubuntu-aoirint -help
docker run --rm aoirint/ffmpeg:ubuntu-aoirint -formats
docker run --rm aoirint/ffmpeg:ubuntu-aoirint -encoders
docker run --rm aoirint/ffmpeg:ubuntu-aoirint -decoders
```
