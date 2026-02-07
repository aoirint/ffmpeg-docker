# AGENTS.md

## 目的

- FFmpeg の Docker イメージをビルドするリポジトリ。

## よく使うコマンド

- 通常ビルド: `make build`
- NVIDIA 対応ビルド: `make build-nvidia`

## CI

- GitHub Actions の設定は `.github/workflows/build.yml`。

## ルール

- コミットメッセージとプルリクエストのタイトルは Conventional Commits のルールに従う。
	- 形式: `<type>[optional scope]: <description>`
	- 参考: https://www.conventionalcommits.org/ja/v1.0.0/
	- 例
		- `feat(variant): 新しいイメージvariantを追加する`
		- `build: FFmpeg を 7.1.3 に更新する`
		- `fix(build): ビルド手順の誤記を修正する`
		- `docs(readme): README の手順を更新する`
- プルリクエストのタイトルと説明文は日本語で書く。
- Markdown ドキュメントは https://github.com/DavidAnson/markdownlint のルールに従う。

### Conventional Commitsのtype一覧

#### feat

- ユーザー向けの新機能を追加したとき。
- 例: 新しいイメージvariantを追加する。

#### fix

- ユーザー向けの不具合を修正したとき。
- 例: nvidia 版のビルド失敗を修正する。

#### docs

- ドキュメントのみを変更したとき。
- 例: NVIDIA ハードウェアコーデックの動作要件を README に追加する。

#### style

- 自動フォーマットや整形のみを行ったとき。
- 例: Dockerfile やシェルスクリプトに空行を追加する。

#### refactor

- 振る舞いを変えずに内部構造を整理したとき（挙動は変更しない）。
- 例: Dockerfile の命令の統廃合を行う、共通処理のステージ化・外部スクリプト化を行う。

#### perf

- ビルド実行時や成果物実行時の処理時間やリソース効率（CI のビルド時間・配布物のファイルサイズ・実行時のメモリ使用量など）を改善したとき（挙動は変更しない）。
- 例: FFmpeg のパフォーマンスチューニングを行う、buildcache の設定を変更して CI のビルド時間を短縮する、イメージサイズを削減する。

#### test

- テストの追加・修正のみを行ったとき。
- 例: 動画変換の動作検証を追加する。

#### build

- ビルドシステム、依存関係や成果物の構成を変更したとき。
- 例: FFmpeg のバージョンを更新する、Dockerfile の syntax を更新する、Makefile のローカルビルド手順を変更する。

#### ci

- CI 設定やワークフローを変更したとき（成果物の構成や挙動には影響しない）。
- 例: CI のステップ順を成果物に影響しない形で変更する、並列ジョブの実行条件を変更する。

#### chore

- 開発補助の作業（ツール更新など）を行ったとき。
- 例: .gitignore など開発用の補助設定を変更する。

#### revert

- 既存コミットの取り消しを行ったとき。
- 例: `revert: "build: FFmpeg を 7.1.3 に更新"`
