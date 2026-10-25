# イメージバリアントと公開モデル

この設計は [FFmpeg ソースと RTMP 派生機能](../domain/ffmpeg-sources.md) を
前提とします。

## ビルド境界

単一の `Dockerfile` が、次の build argument でソースと機能を切り替えます。

| 引数 | 責務 |
| --- | --- |
| `BASE_IMAGE` | Ubuntu または NVIDIA CUDA のビルド基盤 |
| `RUNTIME_IMAGE` | 最終ステージの Ubuntu 24.04 基盤 |
| `BUILD_JOBS` | 各ステージのコンパイル並列数（既定値: 4） |
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

## ライブラリと実行環境の境界

Dockerfile は [Docker のマルチステージビルド](https://docs.docker.com/build/building/multi-stage/)を使います。
`build-base` に固定 snapshot の開発用 package を入れ、`nasm` で assembler をビルドします。
`library-base` はその assembler を共有し、x264、libvpx、LAME、Opus、libaom、SVT-AV1、
libass、dav1d、VMAF をそれぞれ独立したステージでビルドします。
x265 は同じ snapshot の APT package を使い、nv-codec-headers は `nvcodec` ステージで切り替えます。

各ステージは `/out/usr/local` に `DESTDIR` で成果物を集めます。
`ffmpeg-build` が必要なライブラリだけを `/usr/local` に取り込み、FFmpeg をリンクします。
ライブラリの version 引数はそのステージに置き、あるライブラリの更新で兄弟ステージを無効化しません。
共通の base、APT snapshot、assembler、`BUILD_JOBS` の変更は共有するステージを再ビルドします。
独立ステージの同時実行で過剰な compiler process を起動しないよう、各 pool の既定値を 4 に制限します。

最後の `runtime` は固定 Ubuntu 24.04 を使い、FFmpeg / ffprobe / ffplay、既存の x264 / LAME / VMAF CLI、共有ライブラリ、
CA 証明書、字幕用フォント、ライセンス・特許通知を収録します。
TLS の隔離検証にも使う OpenSSL CLI を残します。
compiler、assembler、Git、開発用 header、静的 archive、pkg-config metadata は収録しません。
開発や追加コンパイルには `--target ffmpeg-build` を使います。

NVIDIA 版も最終ステージは Ubuntu です。CUDA / cuDNN の開発イメージはビルド側に限定します。
現在の構成は NVENC / NVDEC を有効にし、NVCC / NPP を使いません。
実行時の driver library はホストの NVIDIA Container Toolkit が供給します。
CUDA decode には `--gpus 'all,"capabilities=compute,video"'` を指定します。
[NVIDIA の capability 定義](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html)
と [実機検証手順](../operations/update-dependencies.md#ローカル検証)を参照してください。

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

`ca-certificates` の `20260816ubuntu0.24.04.1` は cooldown 例外の対象です。
承認日と理由は [CHANGELOG](../../CHANGELOG.md) に記録します。
単一 `.deb` を SHA-256 検証付きで取得し、他の新しい APT パッケージを取り込みません。
CA store を持たない最小 base では、この package の証明書で HTTPS を bootstrap します。

libvpx、libaom、libass は Dockerfile の commit SHA を固定してソースビルドします。
Ninja と Meson も同じ APT snapshot から取得し、別の pip dependency 解決を行いません。
固定 snapshot には zlib、XZ、Unbound、libXtst の確認日時点で公開から 7 日未満の修正が含まれません。
最終 image は実行用 package を明示的にインストールし、Ubuntu package の copyright 情報も保持します。
更新方法は [依存関係更新](../operations/update-dependencies.md) を参照してください。
