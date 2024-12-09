# syntax=docker/dockerfile:1

ARG PLATFORM=linux/arm/v7

FROM --platform=$PLATFORM docker.io/arm32v7/debian:stable AS build

SHELL ["/bin/bash", "-c"]

RUN apt-get update
RUN apt-get install -y \
    build-essential

RUN --network=none groupadd -r builders && useradd --no-log-init -r -g builders builder
USER builder:builders

WORKDIR /build
ADD ./hello.cc .

RUN --network=none g++ -o hello.exe hello.cc

FROM --platform=$PLATFORM docker.io/arm32v7/debian:stable AS app

LABEL org.opencontainers.image.authors="Bryan Honof <bryan.honof+iot@pxl.be>"
LABEL org.opencontainers.image.documentation="https://github.com/bryanhonof/pynq-z2-docker-cicd"
LABEL org.opencontainers.image.source="https://github.com/bryanhonof/pynq-z2-docker-cicd"
LABEL org.opencontainers.image.version="0.0.0"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.ref.name="cpp-pynq-example"
LABEL org.opencontainers.image.title="Pynq Z2 example container for C++"
LABEL org.opencontainers.image.description="\
  Example container showing how to use Docker to build and run programs for the \
  Pynq Z2 \
"

WORKDIR /app

RUN --network=none groupadd -r runners && useradd --no-log-init -r -g runners app
USER app:runners

COPY --chown=app:runners --chmod=100 --from=build /build/hello.exe /app/hello.exe
ADD --chown=app:runners --chmod=700 ./hello.sh .

ENTRYPOINT [ "/app/hello.sh" ]
