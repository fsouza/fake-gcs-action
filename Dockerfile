FROM docker:29.8.1

RUN apk add --no-cache bash
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
