# FFmpeg ソースと RTMP 派生機能

## 対象

- upstream mirror: [FFmpeg/FFmpeg](https://github.com/FFmpeg/FFmpeg)
- fork: [aoirint/FFmpeg](https://github.com/aoirint/FFmpeg)
- 検証した安定版 fork コミット: `c25e55a50cbc4268cfae8d3b66d7b64eb917d9f2`
- 対応する upstream 安定版: `n8.0.3`
- 検証した master コミット: `03dc244a693ce639cebf82f7bae112fb75580919`
- 検証日: 2026-08-11

## ソースの関係

aoirint/FFmpeg の `master` は upstream の `master` を追跡します。安定版の
派生物は upstream の `release/<major>.<minor>` に対応する
`release/<major>.<minor>-aoirint` で管理します。

派生タグは `<version>-aoirint.<revision>` 形式です。たとえば
`8.0.3-aoirint.1` は upstream `n8.0.3` を基点とし、派生パッチを1コミット
追加したタグです。

## `rtmp_strict_paths`

派生パッチは RTMP 入力オプション `rtmp_strict_paths` を追加します。既定値は
無効です。有効にした RTMP listen 処理では、次の不一致を警告で継続せず
I/O エラーとして終了します。

- connect メッセージの application と待受 URL の application
- publish または play の stream 名と待受 URL の stream path

このオプションは組み込みの `rtmp` プロトコルと `librtmp` プロトコルの
オプション一覧へ公開されています。パッチの出典は [FFmpeg Patchwork][patch]
です。

[patch]: https://patchwork.ffmpeg.org/project/ffmpeg/patch/20190925185708.70924-1-unique.will.martin@gmail.com/

## 更新時の検証点

新しい安定版へ移植するときは、オプション登録だけでなく、application と
stream path の両方の不一致経路がエラーを返すことを確認します。upstream の
RTMP 接続処理が変わった場合は、パッチが適用できたことだけを互換性の根拠に
しません。
