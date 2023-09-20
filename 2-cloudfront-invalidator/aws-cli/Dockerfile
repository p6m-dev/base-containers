ARG IMAGE_TAG
FROM amazon/aws-cli:${IMAGE_TAG}

WORKDIR ./
RUN yum install -y jq

COPY . .

WORKDIR ./
ENTRYPOINT ["./entrypoint.sh"]
# Provide DISTRIBUTION_ID as ENV variable or replace CMD with your Cloudfront Distribution Alias
# Replace CMD with your Cloudfront Distribution Alias
CMD ["example.com"]