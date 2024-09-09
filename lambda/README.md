# Python backend running as Amazon Lambda

The file [main.py](./main.py) is the content of the Lambda function.

I decided to stick to the included python packages - mostly to keep the cold start time low.
This made the parsing a bit more ad-hoc and verbose than if had pydantic to my disposal.

The subfolders [.devcontainer](./.devcontainer) and [.vscode](./.vscode) are for local development in VS Code with the extension Remote Development enabled.

The script [lint.sh](./lint.sh) expects to run from a terminal in the containerized VS Code environment.

## S3 configuration

The buckets used in the test setup:

* `taekwondo-test`: This bucket containing the flutter web app.
* `taekwondo-test-public`: Public files on S3. Written by the backend and read by the app
* `taekwondo-test-private`: Private files on S3 used by the backend. Containing e.g. login codes. Used as a cheap replacement for a database.

Both `taekwondo-test` and `taekwondo-test-public` should be publicly available.
The bucket `taekwondo-test` should have "Static website hosting" enabled.
Remember to set a bucket policy for both buckets. For `taekwondo-test-public` this looks like

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::taekwondo-test-public/*"
        }
    ]
}
```

The public bucket should allow CORS:
https://docs.dynatrace.com/docs/setup-and-configuration/setup-on-cloud-platforms/amazon-web-services/aws-platform/set-up-cors-in-amazon-s3#configure-amazon-s3

```
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": []
    }
]
```

Add a CloudFront configuration for the bucket `taekwondo-test` such that it can be accessed on HTTPS.
I have just used the default hostname that CloudFront provides and not bothered to setup a more suitable named hostname.


## Lambda Function config

Based on `Python 3.12` and `arm64`

Configure a Function URL with auth type NONE.

Find the role here https://us-east-1.console.aws.amazon.com/iam/home and give it the permission AmazonS3FullAccess

Adjust the timeout from the default 3 seconds up to 10 seconds
(this shouldn't really be needed, but it's better to have a request succeed a bit slow than to time out).

### Configure to avoid race conditions

But configuring the Lambda Function to run with at most 1 instance at a time we avoid race conditions.

This can be achieved by setting "Reserve concurrency" to 1.

In my case I had an available pool of 10 to distribute the concurrency from.
Then I wasn't able to reserve 1 for my lambda function: "The unreserved account concurrency can't go below 10."

So I had to make a request to increase the pool size: https://eu-central-1.console.aws.amazon.com/servicequotas/home/services/lambda/quotas
And I had to increase it above the default value of 1000! But whatever.

### Memory setting

TL;DR: Allocate 1769 MB to the lambda function.

From documentation: "At 1,769 MB, a function has the equivalent of one vCPU"

Running `boto3.client("s3")` is SLOW!

The speed depends on the allocated memory:

* Default 128 MB: `Executed create_boto_client in 2386.77 ms`
* 256 MB: `Executed create_boto_client in 1170.74 ms`
* 512 MB: `Executed create_boto_client in 554.19 ms`
* 1024 MB: `Executed create_boto_client in 275.49 ms`
* 2048 MB: `Executed create_boto_client in 183.63 ms`

Switching from `boto3` to `botocore` reduced the overhead a bit:

* 2048 MB: `Executed create_s3_client in 146.67 ms`

Now a whole request finished in ~650 ms. Down from the original 