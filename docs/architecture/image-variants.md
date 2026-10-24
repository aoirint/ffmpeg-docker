# イメージバリアントと公開モデル

この設計は [FFmpeg ソースと RTMP 派生機能](../domain/ffmpeg-sources.md) を
前提とします。

## ビルド境界

単一の `Dockerfile` が、次の build argument でソースと機能を切り替えます。

| 引数 | 責務 |
| --- | --- |
| `BASE_IMAGE` | Ubuntu または NVIDIA CUDA のビルド・実行基盤 |
| `FFMPEG_REPOSITORY_URL` | upstream または aoirint fork の Git URL |
| `FFMPEG_VERSION` | clone する完全なコミット SHA |
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

workflow matrix はバリアントごとに1つの FFmpeg 安定版の完全 commit SHA を保持します。
すべての `main` pushは同じ `FFMPEG_VERSION` を使用し、ルートの `VERSION` と
既存release identityの状態により公開タグとキャッシュのライフサイクルだけを
分けます。

このため `edge` は FFmpeg `master` の意味ではなく、次のリリースに入る
ffmpeg-docker の変更を安定版 FFmpeg と組み合わせた継続ビルドです。

## APT とセキュリティ更新

対象は Ubuntu 24.04 系イメージです。確認日: 2026-10-24。
APT は `UBUNTU_SNAPSHOT=20261016T000000Z` の署名付き snapshot に固定し、
base のパッケージも `apt-get upgrade` で更新します。
過去 snapshot の Release 有効期限だけを無効化し、署名検証は維持します。
CUDA の追加 APT repository は無効化し、同梱 CUDA libraries は固定 base の版を維持します。

`ca-certificates` の `20260816ubuntu0.24.04.1` に限り、2026-10-24 に maintainer が
7 日間 cooldown の例外を承認しました。理由は USN-8944-1 の CA distrust です。
単一 `.deb` を SHA-256 検証付きで取得し、他の新しい APT パッケージを取り込みません。
CA store を持たない最小 base では、この package の証明書で HTTPS を bootstrap します。

libvpx 1.17.0、libaom 3.15.0、libass 0.17.5 は commit SHA を固定してソースビルドします。
Ninja と Meson も同じ APT snapshot から取得し、別の pip dependency 解決を行いません。
更新方法は [依存関係更新](../operations/update-dependencies.md) を参照してください。
