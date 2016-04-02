FROM iotdsa/base:latest
MAINTAINER Kenneth Endfinger <k.endfinger@dglogik.com>

WORKDIR /app
VOLUME ["/data"]

COPY pubspec.yaml /app/
COPY tool/docker/run.sh /app/
COPY bin /app/bin/
COPY lib /app/lib/

RUN pub get

WORKDIR /data

CMD ["bash", "/app/run.sh"]
