# FFmpeg ソースと RTMP 派生機能

## 対象

- upstream mirror: [FFmpeg/FFmpeg](https://github.com/FFmpeg/FFmpeg)
- fork: [aoirint/FFmpeg](https://github.com/aoirint/FFmpeg)
- 検証した安定版 fork コミット: `a6838d7635f59fc2115470d15861bdbbecc6cae6`
- 対応する upstream 安定版: `n9.0.2`
- 検証日: 2026-10-24

## ソースの関係

aoirint/FFmpeg の `master` は upstream の `master` を追跡します。安定版の
派生物は upstream の `release/<major>.<minor>` に対応する
`release/<major>.<minor>-aoirint` で管理します。

派生タグは `<version>-aoirint.<revision>` 形式です。たとえば
`8.0.3-aoirint.2` は upstream `n8.0.3` を基点とし、strict path機能と
file-backed stream名を追加した派生タグです。

## `rtmp_strict_paths`

派生パッチは RTMP 入力オプション `rtmp_strict_paths` を追加します。既定値は
無効です。有効にした RTMP listen 処理では、次の不一致を警告で継続せず
I/O エラーとして終了します。

- connect メッセージの application と待受 URL の application
- publish の stream 名と待受 URL の stream path

このオプションは組み込みの `rtmp` プロトコルと `librtmp` プロトコルの
オプション一覧へ公開されています。パッチの出典は [FFmpeg Patchwork][patch]
です。

組み込みの`rtmp`プロトコルでは、`rtmp_strict_stream_file`を併用すると期待する
stream名をローカルファイルから読み取れます。このoptionはlisten modeと
`rtmp_strict_paths`を必須とし、末尾の改行を除いた1つのstream名を受け付けます。
strict path拒否ログは、接続側・期待側いずれのstream名も出力しません。

[patch]: https://patchwork.ffmpeg.org/project/ffmpeg/patch/20190925185708.70924-1-unique.will.martin@gmail.com/

## 更新時の検証点

新しい安定版へ移植するときは、オプション登録だけでなく、application と
stream path の両方の不一致経路がエラーを返すことを確認します。upstream の
RTMP 接続処理が変わった場合は、パッチが適用できたことだけを互換性の根拠に
しません。

## TLS 検証

FFmpeg 9.0.2 の組み込み TLS は peer certificate 検証が既定で有効です。
GnuTLS backend は信頼チェーンと接続先ホスト名を検証します。
旧版からの更新では、従来接続できた未信頼証明書の相手が拒否される場合があります。
検証を無効化せず、隔離した TLS peer で受入・拒否を確認します。

根拠: [n9.0.2 tls.h](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavformat/tls.h)、
[n9.0.2 GnuTLS backend](https://github.com/FFmpeg/FFmpeg/blob/n9.0.2/libavformat/tls_gnutls.c)。
