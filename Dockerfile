FROM thevlang/vlang:alpine as builder
WORKDIR /srv
COPY . .
RUN ["v", "-o", "server", "."]
RUN ["ls"]

FROM alpine
RUN ["apk", "add", "sqlite-libs"]
COPY --from=builder /srv/server .
CMD ["/server"]
