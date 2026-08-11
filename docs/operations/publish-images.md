# Docker イメージの公開

## 公開経路

`.github/workflows/main.yml` は `main` へのpushだけで3バリアントをビルドし、
Docker HubとGHCRへpushします。ルートの `VERSION` が唯一のrelease identityです。

| `VERSION` の状態 | 主な成果物 | GitHub Release |
| --- | --- | --- |
| tagとreleaseが両方存在 | `edge-<variant>` | 作成しない |
| stableでtagとreleaseが両方不在 | `v<version>-<variant>`とlatest系 | stableとして作成 |
| prereleaseでtagとreleaseが両方不在 | `edge-<variant>` | prereleaseとして作成 |

tagとreleaseの片方だけが存在する不整合では、安全のため公開を停止します。
GitHub Releaseの手動作成、tag push、workflow dispatchはリリース経路ではありません。

## 公開手順

1. リリース対象の変更とCHANGELOGを確認します。
2. ルートの `VERSION` をbare SemVerへ変更します。stableは `0.6.0`、prereleaseは
   `0.6.0-rc.1` のように記述し、`v` prefixやbuild metadataは使用しません。
3. Pull Requestの `Check` が成功したら `main` へマージします。
4. main workflowが全variantを一度だけbuild・publishした後、Docker HubとGHCRの
   digest一致およびvariant固有機能を検証したことを確認します。
5. release jobが同じmain commitを指すimmutableな `v<VERSION>` tagとGitHub
   Releaseを作成したことを確認します。
6. stable releaseではversion・variant・`latest` aliases、prereleaseでは既存の
   latest系tagが変わっていないことを確認します。

## 認証と権限

| 種類 | 名前 | 用途 |
| --- | --- | --- |
| Variable | `DOCKERHUB_USERNAME` | Docker Hub login |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub push |
| Secret | `GITHUB_TOKEN` | GHCR pushとrelease作成 |

checkとplanは `contents: read`、buildは `packages: write`、testは
`packages: read`、releaseだけは `contents: write` を使用します。資格情報を
ローカル文書、ログ、PR本文へ転記しません。

## 回復

tagとreleaseの作成前に失敗した場合は原因を修正してmainへpushします。同じ
`VERSION` が未公開なら再試行されます。tagまたはreleaseの片方だけが存在する場合は、
自動修復せず状態を調査します。公開済みのimmutable identityを上書きせず、成果物の
修正が必要なら `VERSION` を増やします。
