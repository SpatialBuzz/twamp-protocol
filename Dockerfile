FROM alpine:3.7 as build_step
LABEL author="Ryan Shaw <ryan.shaw@spatialbuzz.com>"

RUN apk --no-cache add git make gcc libc-dev

ADD . /twamp-protocol

WORKDIR /twamp-protocol

RUN make

RUN chmod +x server

FROM alpine:3.7

RUN apk --no-cache add libcap tini

RUN addgroup -S twamp && adduser -S -G twamp twamp
COPY --from=build_step --chown=twamp:twamp /twamp-protocol/server /usr/local/bin/
COPY health_check.sh /

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/server
EXPOSE 862

STOPSIGNAL SIGINT

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/sbin/tini", "--"]

USER twamp

HEALTHCHECK --interval=5s --timeout=5s --start-period=1s --retries=3 CMD [ "/health_check.sh" ]

CMD [ "/usr/local/bin/server" ]