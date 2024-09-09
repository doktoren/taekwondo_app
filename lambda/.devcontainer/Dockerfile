# FROM amazon/aws-lambda-python:3.12
FROM python:3.12.4-slim-bookworm

RUN apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install --upgrade pip \
    && pip install \
    awslambdaric \
    boto3_stubs \
    botocore \
    jmespath \
    python-dateutil \
    s3transfer \
    simplejson \
    six \
    urllib3 \
    aws_lambda_powertools \
    boto3_stubs \
    black \
    mypy \
    pylint \
    isort

RUN pip install third-party-license-file-generator
