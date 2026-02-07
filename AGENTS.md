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
		- `feat: 新しいコマンドを追加する`
		- `fix(build): ビルド手順の誤記を修正する`
		- `docs(readme): README の手順を更新する`
- プルリクエストのタイトルと説明文は日本語で書く。
- Markdown ドキュメントは https://github.com/DavidAnson/markdownlint のルールに従う。

### Conventional Commitsのtype一覧

#### feat

- ユーザー向けの新機能を追加したとき。

#### fix

- ユーザー向けの不具合を修正したとき。

#### docs

- ドキュメントのみを変更したとき。

#### style

- 仕様に影響しない見た目の変更（空白・整形など）。

#### refactor

- 振る舞いを変えずに内部構造を整理したとき。

#### perf

- 速度やリソース効率を改善したとき。

#### test

- テストの追加・修正のみを行ったとき。

#### build

- ビルドシステムや依存関係に関する変更をしたとき。

#### ci

- CI 設定やワークフローを変更したとき。

#### chore

- 開発補助の作業（ツール更新など）を行ったとき。

#### revert

- 既存コミットの取り消しを行ったとき。
