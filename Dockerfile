FROM golang:1.15-alpine as dev

WORKDIR /work

FROM golang:1.15-alpine as build

WORKDIR /app
COPY ./app/* /app/
RUN go build -o web-app

FROM alpine as runtime
COPY --from=build /app/web-app /
CMD ./web-app
