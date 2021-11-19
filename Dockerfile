FROM docker:20.10.11

RUN apk add --no-cache bash
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
