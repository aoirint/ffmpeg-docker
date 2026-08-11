# Changelog

このプロジェクトの重要な変更を記録します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) を基準とします。
v0.4.0 以前の項目は、2026-08-11 に Git タグ、GitHub Release、コミット履歴から
バックフィルしました。

## [Unreleased]

## [v0.5.0] - 2026-08-11 UTC

### Added

- APM で管理する Agent Skills、固定済み依存関係、第三者ライセンス通知を
  リポジトリへ追加しました。
- upstream FFmpeg、aoirint/FFmpeg、Docker イメージの設計、安定版更新、公開運用を
  `docs/` のドメイン、アーキテクチャ、運用文書へ整理しました。

### Changed

- FFmpeg を最新安定版の upstream `n8.0.3`、aoirint fork
  `8.0.3-aoirint.1` へ更新しました。
- `edge` build を安定版タグから分離し、upstream と aoirint fork が共有する
  `master` コミット `03dc244a693ce639cebf82f7bae112fb75580919` へ更新しました。
- upstream FFmpeg の取得元を、同じタグとコミットを公開する公式GitHub mirrorへ
  統一しました。
- エージェントの作業規則へ fork との責務境界、worktree、検証、PR、文書同期の
  要件を追加しました。
- `edge` タグの説明を、固定した最新の FFmpeg `master` コミットを使用する
  現在の挙動に合わせました。

## [v0.4.0] - 2026-02-09 UTC

### Changed

- FFmpeg を upstream `n7.1.3`、aoirint fork `7.1.3-aoirint.1` へ更新しました。
- Ubuntu、NVIDIA、aoirint fork の version、latest、edge タグ体系を整理し、
  Ubuntu バリアントへ既定タグを割り当てました。
- GitHub Actions の同一系列ビルドへ concurrency group を追加し、古い edge
  ビルドをキャンセルするようにしました。
- Dockerfile の既定 FFmpeg バージョンを CI matrix と一致させました。

### Notes

- NVIDIA ハードウェア codec の動作確認結果を README へ反映しました。
- リポジトリ固有のエージェント指示を追加しました。

## [0.3.0] - 2024-06-08 UTC

### Added

- NVIDIA バリアントで nv-codec-headers をビルドし、FFmpeg の NVIDIA codec
  機能を有効化しました。

### Changed

- FFmpeg を upstream `n7.0.1`、aoirint fork `7.0.1-aoirint.1` へ更新しました。
- Dockerfile frontend、NASM、x264、libvpx、fdk-aac、libaom、SVT-AV1、Ninja、
  Meson、dav1d、libvmaf、nv-codec-headers を更新しました。

## [0.2.4] - 2023-11-11 UTC

### Changed

- FFmpeg を upstream `n6.0.1` へ更新しました。
- Meson を 1.2.3 へ更新しました。

### Notes

- この時点では NVIDIA ハードウェア codec が利用できない既知の制約を README
  に記録していました。この制約は 0.3.0 で解消しました。

## [0.2.3] - 2023-11-04 UTC

### Changed

- aoirint fork を `6.0-aoirint.2` へ更新しました。

### Notes

- GitHub Release では prerelease として公開されました。
- FFmpeg 6.0.1 リリース前の一部コミットを取り込んだ派生版でした。

## [0.2.2] - 2023-10-14 UTC

### Added

- aoirint/FFmpeg を使用する `ubuntu-aoirint` バリアントを追加しました。

### Changed

- FFmpeg の取得元を archive から Git repository へ変更し、CI matrix から
  repository と version を選択できるようにしました。
- 展開後の圧縮済みソースを削除し、Docker build context の一時使用量を
  削減しました。

## [0.2.1] - 2023-10-11 UTC

### Changed

- Dockerfile frontend を 1.6 へ更新しました。
- x264、libvpx、libaom、SVT-AV1、Meson、dav1d を更新しました。
- GitHub Actions の利用 action を更新しました。

### Fixed

- registry cache の `cache-from` から無効な `mode=max` を削除しました。

## [0.2.0] - 2023-05-03 UTC

### Changed

- FFmpeg を 6.0 へ更新しました。
- ベースイメージを Ubuntu 22.04 へ更新しました。
- TLS backend を GnuTLS に統一し、必要な libunistring を追加しました。
- Docker BuildKit の registry cache と依存ツール群を更新しました。

## [20220815.3] - 2022-08-15 UTC

### Changed

- Ubuntu と NVIDIA のイメージ一覧、pull、実行例を README に追加しました。

## [20220815.2] - 2022-08-15 UTC

### Added

- AV1 encoder の SVT-AV1、decoder の dav1d、品質評価 filter の libvmaf を
  FFmpeg build へ追加しました。
- NVIDIA GPU 対応イメージを追加しました。

### Changed

- FFmpeg を 5.1 へ更新しました。
- Docker build を BuildKit heredoc 構文へ移行しました。
- package manager cache と展開済みソースを削除し、イメージを縮小しました。

### Notes

- 2022-08-15 に公開した beta.1 から beta.18 の prerelease 履歴を、この安定版の
  最終状態へ集約しています。

## [v0.1.0.post1] - 2020-09-18 UTC

### Fixed

- Docker Hub への image push に使用する認証設定を修正しました。

## [v0.1.0] - 2020-09-18 UTC

### Added

- Ubuntu 上で FFmpeg と codec 依存関係を source build する Dockerfile を
  追加しました。
- Docker Hub へイメージを公開する GitHub Actions workflow を追加しました。

[Unreleased]: https://github.com/aoirint/ffmpeg-docker/compare/v0.5.0...HEAD
[v0.5.0]: https://github.com/aoirint/ffmpeg-docker/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/aoirint/ffmpeg-docker/compare/0.3.0...v0.4.0
[0.3.0]: https://github.com/aoirint/ffmpeg-docker/compare/0.2.4...0.3.0
[0.2.4]: https://github.com/aoirint/ffmpeg-docker/compare/0.2.3...0.2.4
[0.2.3]: https://github.com/aoirint/ffmpeg-docker/compare/0.2.2...0.2.3
[0.2.2]: https://github.com/aoirint/ffmpeg-docker/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/aoirint/ffmpeg-docker/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/aoirint/ffmpeg-docker/compare/20220815.3...0.2.0
[20220815.3]: https://github.com/aoirint/ffmpeg-docker/compare/20220815.2...20220815.3
[20220815.2]: https://github.com/aoirint/ffmpeg-docker/compare/v0.1.0.post1...20220815.2
[v0.1.0.post1]: https://github.com/aoirint/ffmpeg-docker/compare/v0.1.0...v0.1.0.post1
[v0.1.0]: https://github.com/aoirint/ffmpeg-docker/releases/tag/v0.1.0
