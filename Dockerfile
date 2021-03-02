FROM golang:1.16-alpine as dev

WORKDIR /work

FROM golang:1.16-alpine as build
ARG TAG_NAME
ARG HASH_NAME=default_hash
WORKDIR /app
COPY ./app/* /app/
# RUN go build -o web-app
RUN go build -ldflags "-X main.GitTag=${TAG_NAME} -X main.GitHash=${HASH_NAME}" -o web-app

FROM alpine as runtime
COPY --from=build /app/web-app /
CMD ./web-app
