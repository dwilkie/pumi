FROM alpine:latest

RUN apk update && apk upgrade && apk add --update --no-cache curl gnumeric font-noto-khmer ttf-opensans

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
