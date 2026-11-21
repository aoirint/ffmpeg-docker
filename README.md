# ffmpeg-docker

FFmpeg を Docker で実行するためのイメージです。FFmpeg、ffprobe、ffplay を収録しています。

## イメージを選ぶ

| 用途 | Docker Hub イメージ |
| --- | --- |
| 通常はこちら | `aoirint/ffmpeg:ubuntu` |
| NVIDIA GPU でハードウェアエンコードやデコードを使う | `aoirint/ffmpeg:nvidia` |
| [RTMP のパス制限（rtmp_strict_paths）](docs/domain/ffmpeg-sources.md#rtmp_strict_paths)を使う | `aoirint/ffmpeg:ubuntu-aoirint` |

公開イメージのプラットフォームは `linux/amd64` です。

## Docker で実行する

通常版で FFmpeg のバージョンを表示します。

```shell
docker run --rm aoirint/ffmpeg:ubuntu -version
```

aoirint/FFmpeg 版も同じように起動できます。

```shell
docker run --rm aoirint/ffmpeg:ubuntu-aoirint -version
```

NVIDIA 版で GPU を使うには、ホストで Docker コンテナから GPU を利用できる構成が必要です。
NVENC を使う場合は、Linux・Windows ともに NVIDIA ドライバー 610.0 以降が必要です。

```shell
docker run --rm --gpus all,capabilities=video aoirint/ffmpeg:nvidia -version
```

GPU を使った変換、指定バージョンや edge のタグは [使い方](docs/usage.md) を参照してください。

## 関連文書

- [Docker Hub](https://hub.docker.com/r/aoirint/ffmpeg)
- [変更履歴](CHANGELOG.md)
- [開発者向け文書](docs/README.md)

この構成の FFmpeg は GNU General Public License version 3 or later で提供されます。
詳細は [第三者ソフトウェアの通知](THIRD_PARTY_NOTICES.md) と
[FFmpeg のライセンス情報](https://ffmpeg.org/legal.html)を参照してください。
