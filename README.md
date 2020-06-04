# start-fake-gcs-server

This action is used for starting
[fake-gcs-server](https://github.com/fsouza/fake-gcs-server) in background, as
a Docker container. It starts on port 4443 and supports configuration options
for `-public-host` and `-external-url`.

## Examples

```yaml
steps:
  - uses: fsouza/fake-gcs-action@v0.2.0
    with:
      version: "1.19.3"
      backend: memory
      data: ./testdata
      public-host: "storage.gcs.127.0.0.1.nip.io:8443"
      external-url: "https://storage.gcs.127.0.0.1.nip.io:8443"
  - uses: actions/checkout@v2
```

## Usage

See [action.yml](/action.yml).
