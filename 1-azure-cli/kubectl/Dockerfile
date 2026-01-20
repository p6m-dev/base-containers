FROM public.ecr.aws/docker/library/python:alpine3.18 AS final

# Pull in buildkit builtin args for use
ARG TARGETARCH

# Install Azure CLI
RUN pip install --upgrade pip && pip install azure-cli

# User-defined build args
ARG VERSION=v1.34.3

RUN wget -O /usr/bin/kubectl https://dl.k8s.io/release/${VERSION}/bin/linux/${TARGETARCH}/kubectl && chmod +x /usr/bin/kubectl
RUN apk add jq yq

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
