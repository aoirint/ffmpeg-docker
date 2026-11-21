# 文書一覧

このディレクトリは、ffmpeg-docker と連動する aoirint/FFmpeg の技術的な
事実、設計判断、保守手順を管理します。

Docker イメージを実行する人は、[使い方](usage.md)を参照してください。

## 開発者向け文書

- [ドメイン](domain/README.md): upstream FFmpeg、aoirint/FFmpeg、
  `rtmp_strict_paths` など、リポジトリ外の独立して更新される対象を説明します。
- [アーキテクチャ](architecture/README.md): イメージバリアント、参照関係、
  タグ生成など、このリポジトリ固有の設計を説明します。
- [運用](operations/README.md): FFmpeg 更新、フォーク更新、公開、検証など、
  保守担当者が繰り返す作業を説明します。

エージェントの作業規則は [AGENTS.md](../AGENTS.md) が正本です。
