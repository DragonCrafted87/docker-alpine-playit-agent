#!/usr/bin/env bash

docker buildx build \
    --platform linux/arm64 \
    --tag ghcr.io/dragoncrafted87/alpine-playit-agent \
    .
