#!/bin/sh
docker build -t ffmpeg .
docker build -t ffmpeg:ubuntu --build-arg BASE_IMAGE=ubuntu:bionic .
docker build -t ffmpeg:python --build-arg BASE_IMAGE=python:3 .
