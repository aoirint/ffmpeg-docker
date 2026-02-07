# AGENTS.md

このドキュメントは、AIコーディングエージェントがこのリポジトリを理解し、効率的に作業するためのガイドです。

## リポジトリ概要

- このリポジトリは、FFmpeg の Docker イメージをビルドすることを目的としています。

## よく使うコマンド

ローカルでの開発作業に使う代表的なコマンドです。

- 通常ビルド: `make build`
- NVIDIA ハードウェアコーデック対応版ビルド: `make build-nvidia`

## CI

GitHub Actions の各ワークフローがどのように動作するかを説明します。

### `.github/workflows/build.yml`

- Docker イメージのビルドとレジストリへの公開を行います。

#### Variables / Secrets

|種類|名前|説明|
|:--|:--|:--|
|Variables|`DOCKERHUB_USERNAME`|Docker Hub のユーザー名|
|Secrets|`DOCKERHUB_TOKEN`|Docker Hub のアクセストークン|
|Secrets|`GITHUB_TOKEN`|GHCR への push に使う GitHub Actions のトークン|

## ルール

コミットやプルリクエストに関するルールをまとめます。

- コミットメッセージとプルリクエストのタイトルは Conventional Commits のルールに従います。
	- typeの選択は、以下にある「Conventional Commitsのtype一覧」を参照してください。
	- 形式: `<type>[optional scope]: <description>`
	- 参考: <https://www.conventionalcommits.org/ja/v1.0.0/>
	- 例
		- `feat(variant): 独自フォーク版のvariant ubuntu-aoirint を追加する`
		- `fix(build): nvidia 版のビルドがライブラリ不足で失敗するのを修正する`
		- `docs(readme): NVIDIA ハードウェアコーデックの動作要件を README に追加する`
		- `style(docker): Dockerfile に空行を追加する`
		- `build: FFmpeg のバージョンを更新する`
- プルリクエストのタイトルと説明文は日本語で書きます。
- Markdown ドキュメントは <https://github.com/DavidAnson/markdownlint> のルールに従います。

### Conventional Commitsのtype一覧

このリポジトリで使う type と使いどころの対応表です。

#### feat

- ユーザー向けの新機能を追加したときに使用します。
- 例: イメージのvariantを追加する。

#### fix

- ユーザー向けの不具合を修正したときに使用します。
- 例: nvidia版のビルドがライブラリ不足で失敗するのを修正する。

#### docs

- ドキュメントのみを変更したときに使用します。
- 例: NVIDIA ハードウェアコーデックの動作要件を `README.md` に追加する。

#### style

- 自動フォーマットや整形のみを行ったときに使用します。
- 例: `Dockerfile` やシェルスクリプトに空行を追加する。

#### refactor

- 振る舞いを変えずに内部構造を整理したときに使用します（挙動は変更しません）。
- 例: `Dockerfile` の命令の統廃合を行う、共通処理のステージ化・外部スクリプト化を行う。

#### perf

- ビルド実行時や成果物実行時の処理時間やリソース効率（CI のビルド時間・配布物のファイルサイズ・実行時のメモリ使用量など）を改善したときに使用します（挙動は変更しません）。
- 例: FFmpeg のパフォーマンスチューニングを行う、ビルドキャッシュの設定を変更して CI のビルド時間を短縮する、イメージサイズを削減する。

#### test

- テストの追加・修正のみを行ったときに使用します。
- 例: 動画変換の動作検証を追加する。

#### build

- ビルドシステム、依存関係や成果物の構成を変更したときに使用します。
- 例: FFmpeg のバージョンを更新する、`Dockerfile` の `syntax` を更新する、`Makefile` のローカルビルド手順を変更する。

#### ci

- CI 設定やワークフローを変更したときに使用します（成果物の構成や挙動には影響しません）。
- 例: CI のステップ順を成果物に影響しない形で変更する、並列ジョブの実行条件を変更する。

#### chore

- 開発補助の作業（ツール更新など）を行ったときに使用します。
- 例: `.gitignore` など開発用の補助設定を変更する。

#### revert

- 既存コミットの取り消しを行ったときに使用します。
- 例: `revert: "build: FFmpeg を 7.1.3 に更新"`
