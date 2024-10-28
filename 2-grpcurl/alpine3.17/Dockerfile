ARG BUILDER_IMAGE_TAG="1.21"
ARG IMAGE_TAG="3.17"
FROM ybor/golang:${BUILDER_IMAGE_TAG} as builder
LABEL MAINTAINER="ybor"

# Derived from:
# https://github.com/fullstorydev/grpcurl/blob/v1.8.9/Dockerfile

# create non-privileged group and user
RUN addgroup -S grpcurl && adduser -S grpcurl -G grpcurl

RUN apk add --no-cache git && \
    apk update

# Verions come from branches/tags https://github.com/fullstorydev/grpcurl
ARG VERSION="v1.8.9"
RUN git clone --depth=1 --branch=${VERSION} https://github.com/fullstorydev/grpcurl.git /tmp/fullstorydev/grpcurl

WORKDIR /tmp/fullstorydev/grpcurl

ENV CGO_ENABLED=0
ENV GO111MODULE=on
RUN go build -o /grpcurl \
    -ldflags "-w -extldflags \"-static\" -X \"main.version=${VERSION}\"" \
    ./cmd/grpcurl

FROM ybor/alpine:${IMAGE_TAG} as alpine

WORKDIR /
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /grpcurl /bin/grpcurl
USER grpcurl

ENTRYPOINT ["/bin/grpcurl"]
