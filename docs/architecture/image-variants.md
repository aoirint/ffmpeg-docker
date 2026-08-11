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

- `main` の push は matrix に固定した FFmpeg 安定版から `edge-<variant>` を
  更新します。
- 新しいstable `VERSION` は `v<version>-<variant>` を公開します。
- stable releaseは `<variant>` も更新します。
- prerelease `VERSION` はedge系を検証してGitHub prereleaseを作成し、latest系を
  更新しません。
- `ubuntu` は既定バリアントとして `edge`、`v<version>`、`latest` の別名も
  公開します。

ビルドキャッシュは GHCR だけに保存し、継続ビルド用の
`edge-<variant>-buildcache` と安定リリース用の `<variant>-buildcache` を
分離します。

## ソースrevisionの選択

workflow matrix はバリアントごとに1つの FFmpeg 安定版タグを保持します。
すべての `main` pushは同じ `FFMPEG_VERSION` を使用し、ルートの `VERSION` と
既存release identityの状態により公開タグとキャッシュのライフサイクルだけを
分けます。

このため `edge` は FFmpeg `master` の意味ではなく、次のリリースに入る
ffmpeg-docker の変更を安定版 FFmpeg と組み合わせた継続ビルドです。
