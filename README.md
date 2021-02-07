# Start fake-gcs-server

[![Build Status](https://github.com/fsouza/fake-gcs-action/workflows/Build/badge.svg?branch=main)](https://github.com/fsouza/fake-gcs-action/actions?query=branch:main+workflow:Build)

This action is used for starting
[fake-gcs-server](https://github.com/fsouza/fake-gcs-server) in background, as
a Docker container. It starts on port 4443 and supports configuration options
for `-public-host` and `-external-url`.

## Examples

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: fsouza/fake-gcs-action@v0.3.2
    with:
      version: "1.22.2"
      backend: memory
      data: testdata
      public-host: "storage.gcs.127.0.0.1.nip.io:4443"
      external-url: "https://storage.gcs.127.0.0.1.nip.io:4443"
```

## Usage

See [action.yml](/action.yml).
