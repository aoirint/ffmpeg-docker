# ffmpeg-docker
最新のffmpegを使うためのDockerfile

https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

## build.sh
タグffmpegでDockerイメージとしてビルドする

## run.sh
タグffmpegのついたイメージを起動し、ヘルプを表示する（ENTRYPOINT、`ffmpeg --help`）

引数が与えられた場合、`ffmpeg`にそのまま渡す
