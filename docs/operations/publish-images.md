# Docker イメージの公開

## 公開経路

`.github/workflows/build.yml` は次の event で3バリアントをビルドし、Docker Hub
と GHCR へ push します。

| event | 主な成果物 | キャッシュ |
| --- | --- | --- |
| `main` への push | `edge-<variant>` | `edge-<variant>-buildcache` |
| GitHub Release の作成 | `v<version>-<variant>` | 安定版または edge cache |
| 通常リリース | 上記に加えて `<variant>` と既定別名 | `<variant>-buildcache` |

GitHub Release のタグは `v` で始めます。workflow はそれ以外のタグを拒否します。
prerelease は version tag を公開しますが、latest 系タグを更新しません。

## 公開手順

1. `main` の対象コミットで build workflow が成功し、edge 系イメージが両方の
   レジストリへ公開されたことを確認します。
2. リリース対象の変更と README のタグ説明が一致することを確認します。
3. `v<version>` タグの GitHub Release を作成します。検証中のリリースは
   prerelease にします。
4. release event の全バリアントが成功したことを確認します。
5. Docker Hub と GHCR の両方で期待した version tag を pull し、
   `ffmpeg -version` を実行してソースバージョンを確認します。
6. 通常リリースでは `<variant>` と `latest`、prerelease では既存 latest 系タグが
   変わっていないことを確認します。

## 認証と権限

| 種類 | 名前 | 用途 |
| --- | --- | --- |
| Variable | `DOCKERHUB_USERNAME` | Docker Hub login |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub push |
| Secret | `GITHUB_TOKEN` | GHCR push |

workflow の権限は `contents: read` と `packages: write` に限定します。資格情報を
ローカル文書、ログ、PR本文へ転記しません。

## 回復

公開に失敗した場合は失敗した job と registry を特定し、原因を修正した新しい
コミットまたは新しい GitHub Release で再実行します。公開済みの immutable な
version tag を別内容へ上書きせず、必要ならリポジトリのバージョンを増やします。
