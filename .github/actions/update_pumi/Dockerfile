FROM alpine:latest

RUN apk update && apk upgrade && apk add --update --no-cache curl gnumeric

COPY entrypoint.sh /entrypoint.sh

RUN mkdir -p /github/workspace/tmp/csv_data

ENV APP_HOME /github/workspace/tmp
WORKDIR $APP_HOME

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
