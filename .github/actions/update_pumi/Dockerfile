FROM debian:latest

RUN apt-get update && apt-get install -y gnumeric

COPY entrypoint.sh /entrypoint.sh

ENV APP_HOME /home/user
WORKDIR $APP_HOME

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
