FROM globocom/openvswitch
# COPY docker /usr/local/bin/docker
ARG DOCKER_CLI_VERSION="18.06.3-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

# install docker client
RUN apk --update add curl \
    && mkdir -p /tmp/download \
    && curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download \
    && mv /tmp/download/docker/docker /usr/local/bin/ \
    && rm -rf /tmp/download \
    && apk del curl \
    && rm -rf /var/cache/apk/*

# RUN apk update && apk add -u util-linux bash iproute2 vim py-pip gcc python-dev musl-dev
RUN apk update && apk add -u util-linux bash iproute2 vim py2-netifaces
COPY test.sh /test.sh
