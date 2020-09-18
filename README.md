# ffmpeg-docker
最新のffmpegを使うためのDockerfile

https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu

|tag|base image|
|:--|:--|
|ffmpeg|(same as ffmpeg:ubuntu)|
|ffmpeg:ubuntu|ubuntu:bionic|
|ffmpeg:python|python:3|

## build.sh
Dockerイメージとしてビルドする

## run.sh
Dockerイメージを起動し、ヘルプを表示する（ENTRYPOINT、`ffmpeg --help`）

引数が与えられた場合、`ffmpeg`にそのまま渡す
