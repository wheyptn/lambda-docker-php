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
