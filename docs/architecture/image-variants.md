# イメージバリアントと公開モデル

この設計は [FFmpeg ソースと RTMP 派生機能](../domain/ffmpeg-sources.md) を
前提とします。

## ビルド境界

単一の `Dockerfile` が、次の build argument でソースと機能を切り替えます。

| 引数 | 責務 |
| --- | --- |
| `BASE_IMAGE` | Ubuntu または NVIDIA CUDA のビルド・実行基盤 |
| `FFMPEG_REPOSITORY_URL` | upstream または aoirint fork の Git URL |
| `FFMPEG_VERSION` | clone する完全なタグ、ブランチ、またはコミット |
| `ENABLE_NVCODEC` | NVIDIA codec headers と CUDA configure option の有効化 |

GitHub Actions の matrix が、これらを3つのバリアントへ割り当てます。

| バリアント | FFmpeg ソース | NVIDIA codec |
| --- | --- | --- |
| `ubuntu` | upstream | 無効 |
| `nvidia` | upstream | 有効 |
| `ubuntu-aoirint` | aoirint/FFmpeg | 無効 |

通常版と fork 版で Dockerfile を分岐させず、ソース参照だけを切り替えることで、
派生版固有の差分を aoirint/FFmpeg のパッチへ限定します。

## イメージとタグ

同じ成果物を Docker Hub の `aoirint/ffmpeg` と GHCR の
`ghcr.io/aoirint/ffmpeg` へ公開します。

- `main` の push は `edge-<variant>` を更新します。
- GitHub Release は `v<version>-<variant>` を公開します。
- prerelease でない GitHub Release は `<variant>` も更新します。
- `ubuntu` は既定バリアントとして `edge`、`v<version>`、`latest` の別名も
  公開します。

ビルドキャッシュは GHCR だけに保存し、継続ビルド用の
`edge-<variant>-buildcache` と安定リリース用の `<variant>-buildcache` を
分離します。

## 現在の制約

`edge` は ffmpeg-docker の `main` を継続ビルドするタグです。現在の workflow
は event ごとに `FFMPEG_VERSION` を切り替えないため、upstream または fork の
`master` を自動追跡していません。`edge` を FFmpeg `master` の成果物にするには、
安定版 matrix と別のソース参照を選択する実装変更が必要です。

この制約は README の「main ブランチ最新版」という利用者向け説明と一致して
いません。文書だけで現在の挙動を変更せず、後続の実装修正対象として明示します。
