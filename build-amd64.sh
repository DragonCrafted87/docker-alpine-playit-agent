#!/usr/bin/env bash

docker build \
    --platform linux/amd64 \
    --tag ghcr.io/dragoncrafted87/alpine-playit-agent \
    .
