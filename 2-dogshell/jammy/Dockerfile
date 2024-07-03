FROM naxgrp/python:3.11-jammy

RUN pip install datadog
RUN apt-get update && apt-get install -y jq

COPY entrypoint.sh ./entrypoint.sh

RUN groupadd -r datadog && useradd -r -g datadog datadog

USER datadog

ENTRYPOINT ["./entrypoint.sh"]
CMD ["--help"]
