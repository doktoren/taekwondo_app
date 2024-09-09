#!/bin/bash

flutter build web \
  --dart-define=LAMBDA_HOSTNAME=giiucpryj6hizlsgwvoezpzura0cvcsg.lambda-url.eu-central-1.on.aws \
  --dart-define=S3_HOSTNAME=taekwondo-test-public.s3.eu-central-1.amazonaws.com
