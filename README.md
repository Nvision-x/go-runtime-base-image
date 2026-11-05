# go-runtime-base-image

Runtime base for the static Go services (`CGO_ENABLED=0`). Rebuilt weekly so the
floating tags carry current alpine packages; service repos stop running
`apk upgrade`/`apk add` themselves.

| tag | contents |
|---|---|
| `3.24`, `3`, `latest` | alpine 3.24 + ca-certificates + tzdata + curl, user `app` 1000:1000, WORKDIR `/app` |
| `3.24-cifs`, `latest-cifs` | same + cifs-utils/util-linux, runs as root (mount.cifs) |
| `3.24-YYYYMMDD`, `sha-…` | immutable builds of the above |

Consumer runtime stage:

```dockerfile
FROM ghcr.io/nvision-x/go-runtime-base-image:3.24
COPY --from=builder /box-connector .
CMD ["./box-connector"]
```

Rules for consumers:
- the image already runs as uid 1000; `RUN` steps that write outside `/app`
  need `USER 0` … `USER 1000:1000` around them, or use `COPY --chown=1000:1000`
- Go/stdlib CVEs are fixed by bumping the `golang:` builder tag in the service
  repo, not here
- pin by digest in charts/env repos; the weekly rebuild moves the tags
