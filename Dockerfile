FROM alpine

ENV HOST_UID=1000
ENV HOST_GID=1000
ENV APP_UID=0
ENV APP_GID=0
ENV UNISON_OPTIONS=""
ENV UNISON_WATCH=0

RUN apk update \
    && apk add --no-cache \
        tini \
        bindfs \
        unison \
        --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing

RUN mkdir /sync-host /sync-bind /sync-app

COPY sync-bindfs /bin/

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["sync-bindfs"]
