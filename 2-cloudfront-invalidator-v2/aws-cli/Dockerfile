ARG IMAGE_TAG
FROM ybor/aws-cli:${IMAGE_TAG}

WORKDIR /

COPY . .

WORKDIR /

# Mount Kubernetes Service Account Token to "/var/run/secrets/tokens/sa-token"
# Set ENV variable DISTRIBUTION_ID to the CloudFront Distribution ID
# Set ENV variable ISTIO_ENABLED to true if you are using Istio
# Set ENV variable ROLE_ARN to the AWS IAM Role ARN

ENTRYPOINT ["./entrypoint.sh"]
