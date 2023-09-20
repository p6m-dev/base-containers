ARG IMAGE_TAG
FROM naxgrp/aws-cli:${IMAGE_TAG}

WORKDIR ./

COPY . .

WORKDIR ./
ENTRYPOINT ["./entrypoint.sh"]
# Provide DISTRIBUTION_ID as ENV variable or replace CMD with your Cloudfront Distribution Alias
# Replace CMD with your Cloudfront Distribution Alias
CMD ["example.com"]