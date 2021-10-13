# lambda-docker-php

```bash
docker build -t phplambda:latest .
```

```bash
docker run -p 9000:8080 phplambda:latest
```

```bash
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"queryStringParameters":{"foo":"bar"}}'
```

## SAM

```bash
aws ecr create-repository --repository-name phplambda
sam build
sam local generate-event apigateway aws-proxy > events/apigateway-proxy.json
sam local invoke -e events/apigateway-proxy.json
sam deploy --guided
Looking for config file [samconfig.toml] :  Found
Reading default arguments  :  Success
Stack Name []: phplambda
AWS Region [ap-northeast-1]:
Image Repository for phplambda []: {Account ID}.dkr.ecr.ap-northeast-1.amazonaws.com/phplambda
  phplambda:phpoci to be pushed to {Account ID}.dkr.ecr.ap-northeast-1.amazonaws.com/phplambda:phplambda-abcdefghi-phpoci
Confirm changes before deploy [Y/n]: y
Allow SAM CLI IAM role creation [Y/n]: y
Save arguments to configuration file [Y/n]: y
SAM configuration file [samconfig.toml]:
SAM configuration environment [default]:
Deploy this changeset? [y/N]: y

aws lambda invoke \
   --payload fileb://./event/apigateway-proxy.json \
      --function-name phpstack-phplambda-w0JDE3lNIRlR output ; cat output
```

