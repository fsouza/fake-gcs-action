FROM docker:29.4.1

RUN apk add --no-cache bash
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
