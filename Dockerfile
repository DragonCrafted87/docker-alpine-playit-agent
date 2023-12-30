# syntax=docker/dockerfile:1
FROM alpine:3.19 AS builder

ENV RUSTFLAGS="-C target-feature=-crt-static"
WORKDIR /usr/src

RUN ash <<eot
    apk add --no-cache --update \
        git \
        rust \
        cargo \

    rm -rf /tmp/*
    rm -rf /var/cache/apk/*

    git clone -b v0.15.10 --single-branch https://github.com/playit-cloud/playit-agent.git
eot

WORKDIR /usr/src/playit-agent

RUN ash <<eot
    cargo build --release --bin=playit-cli
eot

FROM alpine:3.19

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="DragonCrafted87 Playit.GG Agent" \
    org.label-schema.description="Alpine Image running the playit.gg agent." \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/DragonCrafted87/docker-alpine-playit-agent" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

RUN ash <<eot
    apk add --no-cache --update \
        libgcc \

    rm -rf /tmp/*
    rm -rf /var/cache/apk/*
eot

ARG USER=docker
ARG UID=1000
ARG GID=1000

RUN ash <<eot
    addgroup \
        --gid "$GID" \
        --system "$USER"

    adduser \
        --disabled-password \
        --gecos "" \
        --ingroup "$USER" \
        --uid "$UID" \
        "$USER"
eot

USER docker

COPY --from=builder /usr/src/playit-agent/target/release/playit-cli /home/docker/playit-agent
WORKDIR /home/docker

ENTRYPOINT ["/home/docker/playit-agent", "--config-file", "playit.toml", "--stdout-logs"]
