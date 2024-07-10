ARG BUILD_FROM
# Build
FROM $BUILD_FROM as buildenv

# Install necessary dependencies
RUN apk --no-cache add gcc protobuf-c-dev build-base git zip curl jq nodejs npm

# Set teddycloud version
ENV TEDDY_CLOUD_VERSION=develop
ENV TEDDY_WEB_VERSION="feat/vite"

# Clone teddycloud
RUN git clone --recurse-submodules  https://github.com/toniebox-reverse-engineering/teddycloud.git --branch=$TEDDY_CLOUD_VERSION

# Workdir to the cloned teddycloud repo
WORKDIR /teddycloud

# Install custom teddycloud_web
RUN rm -rf teddycloud_web
RUN git clone https://github.com/holgerb/teddycloud_web.git --branch=$TEDDY_WEB_VERSION

# Change relative web path to absolute path
#RUN jq '.homepage="./web"' teddycloud_web/package.json > teddycloud_web/package.tmp && mv teddycloud_web/package.tmp teddycloud_web/package.json
#RUN sed -i 's/${process.env.REACT_APP_TEDDYCLOUD_WEB_BASE}/\.\/web/' teddycloud_web/src/i18n.ts
#RUN echo 'REACT_APP_TEDDYCLOUD_API_URL=./web' > teddycloud_web/.env.production
#RUN echo 'REACT_APP_TEDDYCLOUD_WEB_BASE=./web' >> teddycloud_web/.env.production

# No libsanitizie support in alpine and wrong definitions for PRIuTIME
RUN make web zip NO_WARN_FAIL=1 NO_SANITIZERS=1

# Copy tonie infos
RUN curl -f https://raw.githubusercontent.com/toniebox-reverse-engineering/tonies-json/release/tonies.json -o /teddycloud/install/pre/config/tonies.json || true

# Use Alpine Linux as base image for the final image
FROM $BUILD_FROM as runtime
EXPOSE 80 443

# Install necessary runtime dependencies
RUN apk --no-cache add ffmpeg curl ca-certificates bash python3 py3-pip

# Install crudini. This is a workaround until apline supports py3-curdini
RUN pip3 install crudini --break-system-packages

# Update CA certificates
RUN update-ca-certificates

# Create necessary directories
RUN mkdir -p /teddycloud/data/content/default \
    && mkdir -p /teddycloud/data/library \
    && mkdir -p /teddycloud/data/firmware  \
    && mkdir -p /teddycloud/data/www   \
    && mkdir -p /tmp

RUN ln -s /teddycloud /etc/teddycloud

# Copy files from the build environment
COPY --from=buildenv /teddycloud/install/pre/certs/ /teddycloud/certs/
COPY --from=buildenv /teddycloud/install/pre/data/www/ /teddycloud/data/www/

COPY --from=buildenv /teddycloud/install/pre/*.sh /usr/local/bin/
COPY --from=buildenv /teddycloud/install/pre/teddycloud /usr/local/bin/teddycloud
# Why is this here?
COPY --from=buildenv /teddycloud/install/zip/release.zip /tmp/teddycloud.zipyx

## Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]
