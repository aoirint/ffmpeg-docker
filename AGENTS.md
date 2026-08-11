# AGENTS.md

このリポジトリで作業する AI コーディングエージェント向けの指示です。

## リポジトリの役割

このリポジトリは、FFmpeg の安定版と `master` の Docker イメージを
Docker Hub および GitHub Container Registry に公開します。

`ubuntu-aoirint` バリアントは、隣接する `../FFmpeg` の
[aoirint/FFmpeg](https://github.com/aoirint/FFmpeg) フォークと連動します。
このフォークは upstream FFmpeg への追従を最小変更で維持し、安定版へ
`rtmp strict paths` 機能のパッチを適用します。エージェント指示、設計文書、
リリース運用文書はフォーク側ではなく、このリポジトリで管理してください。

## 作業原則

- 実装作業は `origin/main` から `.agents/worktrees/` 配下に隔離 worktree を
  作成して進めます。
- 既存の worktree と、元のチェックアウトにある未コミット変更を保持します。
- Dockerfile、ビルド依存関係、GitHub Actions、公開タグを変更するときは、
  通常版、NVIDIA 版、`ubuntu-aoirint` 版への影響を確認します。
- `ubuntu-aoirint` の参照バージョンを変更するときは、`../FFmpeg` のタグ、
  コミット、パッチ適用状態と対応していることを確認します。
- 秘密値を追跡ファイル、ログ、PR 本文へ含めません。

## Agent Skills

Agent Skills は APM で管理します。作業内容に該当する Skill を使用し、
複数に該当する場合は組み合わせてください。

- APM 依存関係: `apm-workflow`
- 一般的な実装レビュー: `code-quality-check`
- Docker: `docker-quality-check`
- GitHub Actions: `github-actions-quality-check`
- セキュリティとサプライチェーン: `security-check`
- worktree: `git-worktree-workflow`
- コミットメッセージ: `commit-message-quality-check`
- Issue、PR、レビュー、マージ: `github-workflow`
- 文書体系: `software-documentation-maintenance`
- 文書表現: `prose-quality-check`

APM 管理ファイルを変更したら、選定済みの適格な APM CLI で次を実行します。

```shell
apm lock
apm install --frozen
apm audit --ci
```

第三者 Skill は完全なコミット SHA に固定し、`THIRD_PARTY_NOTICES.md` と
ロックファイルを同じ変更で更新します。

## 検証コマンド

```shell
make build
make build-nvidia
```

変更範囲に応じて実行し、環境や所要時間を理由に省略した検証は PR 本文に
明記してください。

## CI と公開

`.github/workflows/build.yml` は `main` への push と GitHub Release の作成を
契機に Docker イメージをビルドし、Docker Hub と GHCR へ公開します。

| 種類 | 名前 | 用途 |
| --- | --- | --- |
| Variable | `DOCKERHUB_USERNAME` | Docker Hub のユーザー名 |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub のアクセストークン |
| Secret | `GITHUB_TOKEN` | GHCR への push |

## コミットとプルリクエスト

- コミットメッセージと PR タイトルは Conventional Commits の
  `<type>[optional scope]: <description>` 形式にします。
- PR のタイトルと本文は日本語で記述します。
- Markdown は markdownlint のルールに従います。
- PR は検証結果と省略事項を記録し、squash merge では
  `<PRタイトル> (#<PR番号>)` をコミット件名に指定します。

主な type は次のとおりです。

| type | 用途 |
| --- | --- |
| `feat` | ユーザー向け機能またはイメージバリアントの追加 |
| `fix` | ユーザー向け不具合の修正 |
| `docs` | 文書のみの変更 |
| `style` | 振る舞いを変えない整形 |
| `refactor` | 振る舞いを変えない内部構造の整理 |
| `perf` | ビルド時間、イメージサイズ、実行効率の改善 |
| `test` | テストのみの変更 |
| `build` | ビルドシステム、依存関係、成果物構成の変更 |
| `ci` | 成果物の挙動を変えない CI の変更 |
| `chore` | ほかの type に該当しない開発補助作業 |
| `revert` | 既存コミットの取り消し |
