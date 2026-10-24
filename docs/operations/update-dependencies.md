# 依存関係更新と隔離検証

## 対象

- Dockerfile の Ubuntu 24.04、upstream / fork FFmpeg、同梱ライブラリ
- 確認日: 2026-10-24
- 依存関係の選定、source PR、ローカル検証、公開前確認を扱います。

## 依存関係の選定

1. FFmpeg の公式タグを署名・完全 SHA・公開日で確認します。
2. fork の新系列は対応する upstream tag を基点に `release/<major>.<minor>-aoirint` を作成します。
   既存系列を上書きせず、別 branch で既存パッチを移植して fork PR を作成します。
3. Dockerfile と main workflow の通常版・NVIDIA 版・fork 版を、確認した完全 SHA に揃えます。
   fork PR が未統合なら、レビュー対象の固定 SHA を使い、merge 前に参照を再確認します。
4. Ubuntu USN と upstream advisory を実際の APT / 静的ライブラリ版と照合します。
   APT の修正は upstream 版番号だけで判断せず、Ubuntu revision と backport を確認します。
5. `UBUNTU_SNAPSHOT` を実行日の 7 日以上前の固定時刻にします。
   base digest、source commit、download checksum、公開日、license もレビューします。
   古い snapshot の署名検証を無効化しないでください。
6. 例外は package と version、理由、承認日を限定して記録します。
   承認は他の package や version に拡張せず、対象を更新するたびに再評価します。

固定入力は Dockerfile と workflow を正本とし、選定根拠と検証結果は PR に記録します。
採用した構成と制約は [イメージ構成](../architecture/image-variants.md#apt-とセキュリティ更新)、
リリースごとの変更と例外承認は [CHANGELOG](../../CHANGELOG.md) を参照してください。

## ローカル検証

Docker daemon と Bash、GNU timeout、tar が必要です。Docker Desktop でも使用できます。
外部サービス、実際の credential、本番 listener は使いません。

```shell
# FORK_COMMIT にレビュー対象の完全 commit SHA を設定してから実行します。
: "${FORK_COMMIT:?Set the reviewed fork commit SHA}"
docker buildx build --check .
docker build -t ffmpeg:review \
  --build-arg FFMPEG_REPOSITORY_URL=https://github.com/aoirint/FFmpeg.git \
  --build-arg "FFMPEG_VERSION=${FORK_COMMIT}" .
scripts/test-rtmp-strict-paths.sh ffmpeg:review
scripts/test-codecs-and-tls.sh ffmpeg:review
```

RTMP test は internal network と一時 volume を作成します。app / stream 拒否、空の stream file、
CRLF、UID/GID 1000:1000 と mode 600、secret 非露出、tee / fifo の 2 出力と片系統の切断・復旧を確認します。
終了時に自分が作成した container、network、volume、log を削除します。
異常終了で残った場合も、実行時の固有名を確認し、そのリソースだけを削除してください。

通常版も build し、NVIDIA 版は `make build-nvidia` と実 GPU 上の encode を別々に確認します。
GPU がなければ実行済みと記録しません。`ffmpeg -L`、同梱 license、`ldd`、APT package 一覧を
最終 image から確認し、source package と静的 library を APT scanner だけで検証しません。

## 公開前確認

最終 image の package version を advisory の修正済み version と照合します。
cooldown により保留した修正は、対象と採用できる時期を PR に記録し、snapshot 更新時に再評価します。
検出されなかったことだけを、既知 CVE がすべて解消した根拠にしません。

fork PR の統合と SHA / 派生 tag の確認を先に行い、image PR の参照を再確認します。
公開する場合は [公開手順](publish-images.md)に従って `VERSION` と変更履歴を更新します。
失敗時は PR を merge せず、既存 image tag / digest を保持します。
