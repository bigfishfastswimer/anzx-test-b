# anzx-test-b


## Build local
```sh
docker build --target runtime . -t anz-test/web-app:${VERSION}
```
## Run
```sh
docker run -p 8080:8080 anz-test/web-app:latest
```