# FFmpeg master の更新

## 目的

aoirint/FFmpeg の `master` を upstream `master` へfast-forwardし、同じ完全な
コミットSHAを ffmpeg-docker の edge buildへ反映します。

## 手順

1. `../FFmpeg` で `origin/master` と `upstream/master` をfetchします。
2. `git merge-base --is-ancestor origin/master upstream/master` で、forkが純粋な
   fast-forwardとして更新できることを確認します。
3. upstream `master` を forkの `master` へpushし、remoteのSHAを読み戻します。
4. `.github/workflows/build.yml` の全バリアントにある `edge_ffmpeg_version` を
   読み戻した40文字のSHAへ更新します。
5. upstream URLとfork URLの両方から同じSHAを取得できることを確認します。
6. `main` へマージしたbuild workflowと、公開されたedge imageの
   `ffmpeg -version` を確認します。

## 失敗時の扱い

fork固有コミットによってfast-forwardできない場合は `master` を強制更新しません。
差分の所有者と移行方法をレビューしてから、mergeまたはrebase方針を決定します。

## 更新契機

edge imageを新しいupstream `master` へ進めるときに実行します。branch名ではなく
完全なSHAを更新するため、定期追従にはffmpeg-docker側の変更と再検証が必要です。
