ARG BUILD_FROM
FROM $BUILD_FROM AS BUILD

ENV LANG C.UTF-8

RUN apk add --no-cache git npm

ENV COMMIT_SHA '7efe8bd5badf0d208aa01b0f05698cd5379b3c83'

RUN git config --global advice.detachedHead false && \
    git clone https://github.com/holgerb/valetudo-mapper -b multi-vacuum /app && \
    cd app && git checkout $COMMIT_SHA

WORKDIR /app
RUN npm install

FROM $BUILD_FROM AS RUNNING

RUN apk add --no-cache npm

WORKDIR /app
COPY --from=BUILD /app /app

ENTRYPOINT [ "/init" ]
CMD []
COPY root /
