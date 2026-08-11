# 運用文書

この区分は、保守担当者が繰り返し実行する更新・公開手順を管理します。

## 文書一覧

- [FFmpeg 安定版の更新](update-stable-ffmpeg.md): upstream リリースの確認、
  aoirint fork のパッチ移植、Docker matrix 更新、公開前検証を説明します。
- [FFmpeg master の更新](update-master-ffmpeg.md): Docker の安定版参照とは独立した
  fork のfast-forwardを説明します。
- [Docker イメージの公開](publish-images.md): `main` と GitHub Release から
  Docker Hub・GHCR へ公開される処理と確認事項を説明します。

workflow、レジストリ、認証、リリース規則、更新対象ファイルが変わったときに
この区分を更新します。
