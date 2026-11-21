# Docker イメージの使い方

初めて使う場合は、[README の実行例](../README.md#docker-で実行する)から始めてください。

## タグ

以下は [Docker Hub の `aoirint/ffmpeg`](https://hub.docker.com/r/aoirint/ffmpeg) のタグです。
安定版タグはプレリリースを指さず、edge タグは `main` のビルドを指します。

| バリアント | 最新の安定版 | バージョン指定 | edge |
| --- | --- | --- | --- |
| 通常版 | `ubuntu` | `v<version>-ubuntu` | `edge-ubuntu` |
| NVIDIA 版 | `nvidia` | `v<version>-nvidia` | `edge-nvidia` |
| aoirint/FFmpeg 版 | `ubuntu-aoirint` | `v<version>-ubuntu-aoirint` | `edge-ubuntu-aoirint` |

`latest`、`v<version>`、`edge` はそれぞれ通常版の対応するタグと同じイメージを指します。
イメージをあらかじめ取得するには、例えば `docker pull aoirint/ffmpeg:ubuntu` を実行します。

## 入出力ファイルを指定する

作業ディレクトリをコンテナにマウントし、そこにある `input.mp4` から音声を取り出す例です。
Bash などの POSIX 互換シェルで実行します。

```shell
docker run --rm --mount "type=bind,source=${PWD},target=/work" -w /work \
  aoirint/ffmpeg:ubuntu -i input.mp4 -vn output.mp3
```

## NVIDIA GPU を使う

Linux ホストでは NVIDIA Container Toolkit を設定します。
NVENC を使う前に、[README のドライバー要件](../README.md#docker-で実行する)を確認してください。

CUDA でデコードし、NVENC で H.264 にエンコードする例です。
上と同じディレクトリで実行します。

```shell
docker run --rm --gpus 'all,"capabilities=compute,video"' \
  --mount "type=bind,source=${PWD},target=/work" -w /work aoirint/ffmpeg:nvidia \
  -hwaccel cuda -hwaccel_output_format cuda -i input.mp4 -c:v h264_nvenc output-nvenc.mp4
```

旧 Mesa VDPAU バックエンドは Ubuntu 26.04 ベースのイメージには含まれません。
VA-API や CUDA/CUVID への移行は
[ハードウェアデコードの範囲](architecture/image-variants.md#ハードウェア-decode-の範囲)を参照してください。

## FFmpeg の機能を調べる

`-help`、`-formats`、`-encoders`、`-decoders` で、
選んだイメージのヘルプや対応形式・コーデックを確認できます。

```shell
docker run --rm aoirint/ffmpeg:ubuntu -encoders
```
