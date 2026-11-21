# イメージバリアントと公開モデル

この設計は [FFmpeg ソースと RTMP 派生機能](../domain/ffmpeg-sources.md) を
前提とします。

## ビルド境界

単一の `Dockerfile` が、次の build argument でソースと機能を切り替えます。

| 引数 | 責務 |
| --- | --- |
| `BASE_IMAGE` | Ubuntu または NVIDIA CUDA のビルド基盤 |
| `RUNTIME_IMAGE` | 最終ステージの Ubuntu 26.04 基盤 |
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

最後の `runtime` は固定 Ubuntu 26.04 を使い、FFmpeg / ffprobe / ffplay、既存の x264 / LAME / VMAF CLI、共有ライブラリ、
CA 証明書、字幕用フォント、ライセンス・特許通知を収録します。
TLS の隔離検証にも使う OpenSSL CLI を残します。
compiler、assembler、Git、開発用 header、静的 archive、pkg-config metadata は収録しません。

NVIDIA 版のビルド基盤は CUDA 13.4.3 / cuDNN の Ubuntu 26.04 イメージです。
Ubuntu と CUDA の公式 tag・manifest を確認し、双方を index digest へ固定します。
公式 base の manifest は Ubuntu が amd64 / armv7 / arm64 / ppc64le / riscv64 / s390x、CUDA が amd64 / arm64 を提供します。
このリポジトリの CI がビルド・検証する公開 image は linux/amd64 です。他の architecture の動作は未検証です。

NVIDIA 版も最終ステージは Ubuntu です。CUDA / cuDNN の開発イメージはビルド側に限定します。
現在の構成は NVENC / NVDEC を有効にし、NVCC / NPP を使いません。
実行時の driver library はホストの NVIDIA Container Toolkit が供給します。
CUDA decode には `--gpus 'all,"capabilities=compute,video"'` を指定します。
[NVIDIA の capability 定義](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html)
と [実機検証手順](../operations/update-dependencies.md#ローカル検証)を参照してください。

## ハードウェア decode の範囲

NVIDIA の公開対応は NVENC / NVDEC です。ホストの NVIDIA driver を使い、Mesa の VDPAU driver には依存しません。
通常版・fork 版も VA-API の library と `va-driver-all` を保持します。
AMD 向け Mesa VA-API や Intel 向け driver、および SDL / OpenGL の依存を VDPAU と一緒に削除しません。
実際に使える GPU と codec はホスト driver、device の公開方法、各 backend に依存します。

Ubuntu 26.04 には `vdpau-driver-all` がありません。
[Mesa 25.3 の公式変更履歴](https://docs.mesa3d.org/relnotes/25.3.0.html)で VDPAU frontend は廃止され、
26.04 の `mesa-libgallium` にも旧 Mesa VDPAU driver の実体はありません。
このため旧版に同梱していた Mesa VDPAU backend の互換性は維持しません。
`libvdpau1` と FFmpeg 側の VDPAU API は保持しますが、同梱 Mesa backend があることは意味しません。
旧同梱 Mesa backend で `-hwaccel vdpau` を使う場合は、対応 GPU の VA-API または NVIDIA の CUDA / CUVID decode へ移行が必要です。
VDPAU は API であり、古い GPU 専用という意味ではありません。FFmpeg の VDPAU API とホストが提供する別の driver 実装は区別します。
[FFmpeg の定義](https://ffmpeg.org/ffmpeg.html#Advanced-Video-options)と
[NVIDIA の VDPAU 実装](https://download.nvidia.com/XFree86/Linux-x86_64/610.57.04/README/vdpausupport.html)を参照してください。

旧同梱 backend の構成は [Ubuntu 24.04 の v0.9.0](https://github.com/aoirint/ffmpeg-docker/releases/tag/v0.9.0) に残しています。

`libvdpau-va-gl1` は別の VA-API / OpenGL 変換 driver です。
[上流の実行条件](https://github.com/i-rinat/libvdpau-va-gl/tree/v0.4.2)には VA-API / OpenGL と driver 選択設定があり、
旧 Mesa backend と同等と確認していないため、自動的な置換としては同梱しません。

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

## Dockerfile の依存入力

依存関係ごとに公式の配布形式が異なります。ビルドや版の識別に必要な情報を保持できる
形式を選び、入力を次のように固定します。

- **Git**: libaom は公式リリースに対応する完全なコミット SHA を `AOM_VERSION` に指定し、
  `git fetch --depth 1 origin "${AOM_VERSION}"` で取得します。対応するタグは `# Git Tag: v3.15.3` のように示します。
- **公式配布アーカイブ**: Opus は版情報を含むリリースアーカイブを `OPUS_VERSION` で指定します。
  配布元や信頼できるパッケージ情報で確認した SHA-256 を `OPUS_SHA256` に指定し、
  `sha256sum --check` で展開前に照合します。NASM と LAME も同じ方式です。
- **APT**: `UBUNTU_SNAPSHOT` で [署名付き Ubuntu スナップショット](#apt-とセキュリティ更新)の時点を固定します。
- **ベースイメージ**: `ubuntu:26.04@sha256:<digest>` のように、タグを添えて digest で固定します。

Dockerfile はイメージの構築と、ハッシュや署名による取得物の検証を担います。
最終イメージのパッケージ版、信頼ストア、実行時の挙動はビルド後のテストで確認します。
入力の出所確認と更新手順は [依存関係更新](../operations/update-dependencies.md) を参照してください。

## APT とセキュリティ更新

ビルドとランタイムの APT は、同じ Ubuntu 26.04 スナップショットを HTTPS で使います。
過去のスナップショットに対する Release の有効期限チェックのみ無効にし、
TLS 証明書とアーカイブ署名は引き続き検証します。
CUDA の追加 APT リポジトリは無効にし、同梱の CUDA ライブラリはベースイメージの版を維持します。

最初の APT 取得に使う CA バンドルは、署名付きインデックスと照合した Ubuntu の
`ca-certificates` パッケージから展開します。初回取得後は、両ステージとも APT で
`ca-certificates` をインストールし、インストール済み証明書から信頼ストアを生成します。
初回取得用のパッケージでインストール済みの版を上書きすることはありません。

Ninja と Meson も同じ APT snapshot から取得し、別の pip dependency 解決を行いません。
snapshot より新しいセキュリティ更新は、対象パッケージと Ubuntu revision を更新ごとに照合します。
最終 image は実行用 package を明示的にインストールし、Ubuntu package の copyright 情報も保持します。
更新方法は [依存関係更新](../operations/update-dependencies.md) を参照してください。
