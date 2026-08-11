# FFmpeg 安定版の更新

## 目的

新しい upstream FFmpeg 安定版と、それに `rtmp_strict_paths` パッチを適用した
aoirint 派生版を同じ ffmpeg-docker リリースで公開できる状態にします。

## 前提

- `ffmpeg-docker` と `../FFmpeg` の両方を取得していること
- `../FFmpeg` に `origin` と `upstream` remote が設定されていること
- aoirint/FFmpeg と ffmpeg-docker へ push できること
- Docker Hub と GHCR の公開資格情報が GitHub Actions に設定されていること

## 手順

1. aoirint/FFmpeg で `origin` と `upstream` を fetch し、新しい upstream の
   `n<version>` タグと対応する `release/<major>.<minor>` を確認します。
2. 対応する `release/<major>.<minor>-aoirint` を upstream release branch と
   同期し、`rtmp_strict_paths` パッチを移植します。
3. [ドメイン文書の検証点](../domain/ffmpeg-sources.md#更新時の検証点)に従い、
   application と stream path の不一致が有効時だけ I/O エラーになることを
   aoirint/FFmpeg 側で検証します。
4. aoirint/FFmpeg に `<version>-aoirint.<revision>` タグを作成し、対象ブランチと
   タグを公開します。Docker 側から参照できることを `git ls-remote` で確認します。
5. ffmpeg-docker の `Dockerfile` にある既定 `FFMPEG_VERSION` を
   `n<version>` へ更新します。
6. `.github/workflows/main.yml` の `ubuntu` と `nvidia` を `n<version>`、
   `ubuntu-aoirint` を `<version>-aoirint.<revision>` へ更新します。
7. Dockerfile と workflow に旧バージョンが残っていないことを検索し、
   `make build` と `make build-nvidia` を実行します。
8. PR では upstream タグ、fork タグ、パッチ検証、Docker 検証結果を記録します。
   マージ後は [Docker イメージの公開](publish-images.md)へ進みます。

## 失敗時の扱い

- upstream の RTMP 実装変更でパッチの意味を確認できない場合は、fork タグと
  Docker 更新を公開せず、移植方法を先にレビューします。
- Docker ビルドが失敗した場合は、成功済みの既存タグを移動しません。
- 誤った fork タグを公開した場合は同名タグを上書きせず、修正コミットから
  revision を増やした新しい派生タグを作成します。

## 更新契機

新しい FFmpeg 安定版、安定版 point release、または派生パッチの修正が必要に
なったときに実行します。
