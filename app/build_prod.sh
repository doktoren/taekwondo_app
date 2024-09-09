#!/bin/bash

flutter build web \
  --dart-define=LAMBDA_HOSTNAME=nxs7ohc4iutdnwp2u45xbphxly0murpo.lambda-url.eu-central-1.on.aws \
  --dart-define=S3_HOSTNAME=struer-taekwondo-public.s3.eu-central-1.amazonaws.com
