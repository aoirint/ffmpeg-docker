# 開発者向け文書

このディレクトリは、ffmpeg-docker と連動する aoirint/FFmpeg の技術的な
事実、設計判断、保守手順を管理します。

## 文書区分

- [ドメイン](domain/README.md): upstream FFmpeg、aoirint/FFmpeg、
  `rtmp_strict_paths` など、リポジトリ外の独立して更新される対象を説明します。
- [アーキテクチャ](architecture/README.md): イメージバリアント、参照関係、
  タグ生成など、このリポジトリ固有の設計を説明します。
- [運用](operations/README.md): FFmpeg 更新、フォーク更新、公開、検証など、
  保守担当者が繰り返す作業を説明します。

利用者向けのイメージ名、pull、実行例はルートの [README](../README.md) が
正本です。エージェントの作業規則は [AGENTS.md](../AGENTS.md) が正本です。
