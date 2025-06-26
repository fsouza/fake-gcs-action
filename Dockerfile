FROM docker:28.3.0

RUN apk add --no-cache bash
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
