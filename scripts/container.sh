#!/bin/bash

# Auto Configure Project Path And Additional Variables
# shellcheck disable=SC2164
scriptPath="$( cd "$(dirname "$0")" ; pwd -P )"
projectPath="$(dirname "${scriptPath}")"
AWS_REGION=${AWS_REGION:-$(grep "awsRegion" "${projectPath}/project.conf" | cut -d= -f 2)}
CMDLINE=${CMDLINE:-'alpine:latest /bin/bash'}

# Execute An Interactive Docker Session
# shellcheck disable=SC2086
docker run -t --rm \
    -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN \
    -e AWS_SECURITY_TOKEN -e AWS_REGION -e AWS_DEFAULT_REGION="${AWS_REGION}" -v ${HOME}/.aws:/home/user/.aws \
    -e http_proxy -e https_proxy -e HTTP_PROXY -e HTTPS_PROXY -e no_proxy \
    --volume /tmp:/tmp --volume "${projectPath}:/project" --volume /etc/ssl/certs:/etc/ssl/certs \
    ${CMDLINE}
