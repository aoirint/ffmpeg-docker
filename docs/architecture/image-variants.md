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

- `main` の push は matrix に固定した FFmpeg `master` コミットから
  `edge-<variant>` を更新します。
- GitHub Release は `v<version>-<variant>` を公開します。
- prerelease でない GitHub Release は `<variant>` も更新します。
- `ubuntu` は既定バリアントとして `edge`、`v<version>`、`latest` の別名も
  公開します。

ビルドキャッシュは GHCR だけに保存し、継続ビルド用の
`edge-<variant>-buildcache` と安定リリース用の `<variant>-buildcache` を
分離します。

## ソースrevisionの選択

workflow matrix は安定版タグと edge 用 `master` コミットを別々に保持します。
GitHub Release では安定版タグを、`main` の push では完全な40文字のコミットSHAを
`FFMPEG_VERSION` に渡します。

upstream と aoirint fork の `master` は同じコミットへfast-forwardした状態で
edge revisionを更新します。branch名を直接cloneせず完全なコミットSHAに固定し、
同じffmpeg-docker commitの再ビルド結果が意図せず変わることを防ぎます。
