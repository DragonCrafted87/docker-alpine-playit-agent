FROM alpine:3.16 as builder

ENV RUSTFLAGS="-C target-feature=-crt-static"
WORKDIR /usr/src

RUN apk add --no-cache --update \
    git \
    rust \
    cargo \
    && \
    rm  -rf /tmp/* /var/cache/apk/*

RUN  git clone https://github.com/DragonCrafted87/playit-agent.git

WORKDIR /usr/src/playit-agent
RUN   git reset --hard 18e692e513437c792c4b56977b72db33342a22c4 \
      && \
      cargo build --release --bin=agent



FROM alpine:3.16

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DragonCrafted87 Alpine Minecraft" \
      org.label-schema.description="Alpine Image with OpenJDK to run a minecraft server." \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/DragonCrafted87/docker-alpine-minecraft" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"


RUN apk add --no-cache --update \
    libgcc \
    && \
    rm  -rf /tmp/* /var/cache/apk/*

ARG USER=docker
ARG UID=9999
ARG GID=9999

RUN addgroup \
            --gid "$GID" \
            --system "$USER" \
      && \
      adduser \
            --disabled-password \
            --gecos "" \
            --ingroup "$USER" \
            --uid "$UID" \
            "$USER"

USER docker

COPY --from=builder /usr/src/playit-agent/target/release/agent /home/docker/playit-agent
WORKDIR /home/docker

ENTRYPOINT ["/home/docker/playit-agent", "--config-file", "playit.toml", "--stdout-logs"]
