# ffmpeg-docker

最新のFFmpegを使うためのDockerイメージ

- <https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu>

設計、FFmpeg fork との連動、更新・公開手順は
[開発者向け文書](docs/README.md)を参照してください。
変更履歴は [CHANGELOG](CHANGELOG.md)を参照してください。

## 配布する第三者ソフトウェア

Docker イメージは、`Dockerfile` の `FFMPEG_VERSION` と build workflow の
`ffmpeg_version` で指定した [FFmpeg](https://ffmpeg.org/) を収録します。このビルド構成の
FFmpeg は GNU General Public License version 3 or later で提供されます。
詳細は [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) と
[FFmpeg のライセンス情報](https://ffmpeg.org/legal.html)を参照してください。

## タグ一覧

|バリアント|イメージ|説明|
|:--|:--|:--|
|latest|`aoirint/ffmpeg:latest`|`ffmpeg:ubuntu` と同じ|
|latest|`aoirint/ffmpeg:v<version>`|`ffmpeg:v<version>-ubuntu` と同じ|
|latest|`aoirint/ffmpeg:edge`|`ffmpeg:edge-ubuntu` と同じ|
|ubuntu|`aoirint/ffmpeg:ubuntu`|ubuntu版の最新リリース（プレリリース除く）|
|ubuntu|`aoirint/ffmpeg:v<version>-ubuntu`|ubuntu版の指定バージョン|
|ubuntu|`aoirint/ffmpeg:edge-ubuntu`|ubuntu版のmainブランチ最新ビルド|
|nvidia|`aoirint/ffmpeg:nvidia`|NVIDIA GPU ハードウェアコーデック対応版の最新リリース（プレリリース除く）|
|nvidia|`aoirint/ffmpeg:v<version>-nvidia`|NVIDIA GPU ハードウェアコーデック対応版の指定バージョン|
|nvidia|`aoirint/ffmpeg:edge-nvidia`|NVIDIA GPU対応版のmainブランチ最新ビルド|
|ubuntu-aoirint|`aoirint/ffmpeg:ubuntu-aoirint`|aoirint Fork版の最新リリース（プレリリース除く）|
|ubuntu-aoirint|`aoirint/ffmpeg:v<version>-ubuntu-aoirint`|aoirint Fork版の指定バージョン|
|ubuntu-aoirint|`aoirint/ffmpeg:edge-ubuntu-aoirint`|aoirint Fork版のmainブランチ最新ビルド|

- Docker Hub: <https://hub.docker.com/r/aoirint/ffmpeg>

## ビルドキャッシュ

|バリアント|イメージ|説明|
|:--|:--|:--|
|ubuntu|`ghcr.io/aoirint/ffmpeg:ubuntu-buildcache`|ubuntu版のbuildcache（latest系）|
|ubuntu|`ghcr.io/aoirint/ffmpeg:edge-ubuntu-buildcache`|ubuntu版のbuildcache（edge系）|
|nvidia|`ghcr.io/aoirint/ffmpeg:nvidia-buildcache`|NVIDIA GPU ハードウェアコーデック対応版のbuildcache（latest系）|
|nvidia|`ghcr.io/aoirint/ffmpeg:edge-nvidia-buildcache`|NVIDIA GPU ハードウェアコーデック対応版のbuildcache（edge系）|
|ubuntu-aoirint|`ghcr.io/aoirint/ffmpeg:ubuntu-aoirint-buildcache`|aoirint Fork版のbuildcache（latest系）|
|ubuntu-aoirint|`ghcr.io/aoirint/ffmpeg:edge-ubuntu-aoirint-buildcache`|aoirint Fork版のbuildcache（edge系）|

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
