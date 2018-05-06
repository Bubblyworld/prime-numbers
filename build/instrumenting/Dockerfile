# Base image is the ultra-light Alpine Linux container.
# See: https://github.com/gliderlabs/docker-alpine
FROM gliderlabs/alpine

ADD /bundle.tar.gz /

EXPOSE 8080
CMD ["/instrumenting"]