# FFmpeg ソースと RTMP 派生機能

## 対象

- upstream: [FFmpeg/FFmpeg](https://github.com/FFmpeg/FFmpeg)
- fork: [aoirint/FFmpeg](https://github.com/aoirint/FFmpeg)
- 検証した fork コミット: `c83b178c0e19e35a8d034e1595780c1c03714c4a`
- 検証日: 2026-08-11

## ソースの関係

aoirint/FFmpeg の `master` は upstream の `master` を追跡します。安定版の
派生物は upstream の `release/<major>.<minor>` に対応する
`release/<major>.<minor>-aoirint` で管理します。

派生タグは `<version>-aoirint.<revision>` 形式です。たとえば
`7.1.3-aoirint.1` は upstream `n7.1.3` を基点とし、派生パッチを1コミット
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
