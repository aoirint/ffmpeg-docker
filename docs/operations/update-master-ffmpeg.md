# FFmpeg master の更新

## 目的

aoirint/FFmpeg の `master` を upstream `master` へfast-forwardします。
ffmpeg-docker のイメージは安定版タグを使用するため、この操作では
Docker workflowの参照versionを変更しません。

## 手順

1. `../FFmpeg` で `origin/master` と `upstream/master` をfetchします。
2. `git merge-base --is-ancestor origin/master upstream/master` で、forkが純粋な
   fast-forwardとして更新できることを確認します。
3. upstream `master` を forkの `master` へpushし、remoteのSHAを読み戻します。
4. upstream URLとfork URLの両方から同じSHAを取得できることを確認します。
5. ffmpeg-docker の workflow matrix にmaster SHAを追加していないことを
   確認します。

## 失敗時の扱い

fork固有コミットによってfast-forwardできない場合は `master` を強制更新しません。
差分の所有者と移行方法をレビューしてから、mergeまたはrebase方針を決定します。

## 更新契機

aoirint/FFmpeg の `master` を新しいupstream `master` へ進めるときに実行します。
Docker イメージの FFmpeg revision は、安定版更新の手順でのみ変更します。
