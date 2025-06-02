FROM docker:28.2.2

RUN apk add --no-cache bash
ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
