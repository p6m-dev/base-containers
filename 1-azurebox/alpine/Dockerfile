ARG VERSION=v1.34.3

FROM registry.k8s.io/kubectl:${VERSION} AS kubectl

FROM public.ecr.aws/docker/library/python:alpine3.18 AS final

# Pull in buildkit builtin args for use
ARG TARGETARCH

# Install Azure CLI
RUN pip install --no-cache --upgrade pip && pip install --no-cache azure-cli

RUN apk update && apk add --no-cache jq yq
COPY --from=kubectl /bin/kubectl /usr/local/bin/kubectl
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
