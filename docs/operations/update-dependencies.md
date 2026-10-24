# 依存関係更新と隔離検証

## 対象

- Dockerfile の Ubuntu 24.04、upstream / fork FFmpeg、同梱ライブラリ
- 確認日: 2026-10-24
- 本手順は source PR とローカル検証まで。merge、tag、image 公開、deployment は別の操作です。

## 更新するもの

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
   今回の承認は `ca-certificates=20260816ubuntu0.24.04.1` だけです。
   他の直近修正に例外を拡張しません。

## 今回の選定

| 入力 | 固定値 | 公開時期・根拠 |
| --- | --- | --- |
| FFmpeg | n9.0.2 / `946fcce07b6dcd0331c8cc609192aeff5e1924f8` | 2026-09-18、公式タグ |
| libvpx | 1.17.0 / `6df3ec34557879fff673706f4a1d9fbd0f3a6f0e` | 2026-08、upstream tag |
| libaom | 3.15.0 / `de4c1d1edc49723a78954d30a83690aa1937422f` | 2026-08-25、upstream tag |
| libass | 0.17.5 / `4a05d8127f525943ebf45fdc6497c9e665947f0d` | 2026-06-24、upstream tag |
| APT | `20261016T000000Z` | 2026-10-24 時点で 7 日以上経過 |
| CA exception | `20260816ubuntu0.24.04.1` | 2026-10-20 公開、2026-10-24 承認 |
| Dockerfile frontend | 1.19.0、Dockerfile の index digest | 2025-09-30 build |

CA package は 2026-10-23 snapshot の noble-security Packages index の SHA-256 に固定しています。
例外理由は [USN-8944-1](https://ubuntu.com/security/notices/USN-8944-1) の CA distrust です。
Ninja / Meson は APT snapshot に統一し、pip の追加依存解決をなくしています。
他の source library / build tool の既存参照は今回変更していません。

## ローカル検証

Docker daemon と Bash、GNU timeout、tar が必要です。Docker Desktop でも使用できます。
外部サービス、実際の credential、本番 listener は使いません。

```shell
docker buildx build --check .
docker build -t ffmpeg:review \
  --build-arg FFMPEG_REPOSITORY_URL=https://github.com/aoirint/FFmpeg.git \
  --build-arg FFMPEG_VERSION=be9184f722387eddad52a138a7c9611afb589d3e .
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

## 残る確認と公開順序

7 日未満の zlib、XZ、Unbound、libXtst 修正は固定 snapshot に含めていません。
次回 snapshot 更新時に再評価してください。未使用 build package が image に残る従来構成も維持します。
本更新は既知 CVE がすべて解消したという保証ではありません。

fork PR の統合と SHA / 派生 tag の確認を先に行い、image PR の参照を再確認します。
`VERSION` と release 日は今回変更しません。公開を決めた時点で
[公開手順](publish-images.md)に従って更新します。
失敗時は PR を merge せず、既存 image tag / digest を保持します。
