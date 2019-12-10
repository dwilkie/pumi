FROM debian:latest

RUN apt-get update && apt-get install -y gnumeric curl

COPY entrypoint.sh /entrypoint.sh

RUN mkdir -p /github/workspace/tmp/csv_data

ENV APP_HOME /github/workspace/tmp
WORKDIR $APP_HOME

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
