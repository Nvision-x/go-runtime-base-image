# syntax=docker/dockerfile:1
# base tag is written inline: Dependabot drops FROM lines whose tag is an ARG
FROM alpine:3.24 AS runtime
# apk upgrade: base-layer fixes (openssl/musl/busybox) land between alpine point releases
RUN apk upgrade --no-cache \
    && apk add --no-cache ca-certificates tzdata \
    && addgroup -g 1000 -S app \
    && adduser -u 1000 -S -G app -h /app -s /sbin/nologin app
WORKDIR /app
# numeric so runAsNonRoot can verify it; the charts already run 1000:1000
USER 1000:1000

FROM runtime AS cifs
USER 0
# mount.cifs needs root; cifs-connector runs privileged and execs mount/umount
RUN apk add --no-cache cifs-utils util-linux
