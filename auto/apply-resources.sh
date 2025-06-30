#!/usr/bin/env sh

set -euo pipefail

cd $(dirname $0)/..

eval $(minikube docker-env)

docker build -t login-api:latest .

encoded_tls_key=$(cat tls.key | base64 | tr -d '\n')
encoded_tls_crt=$(cat tls.crt | base64 | tr -d '\n')

sed -i '' "s/BASE64_ENCODED_KEY/${encoded_tls_key}/" ./deployment/values.yaml
sed -i '' "s/BASE64_ENCODED_CRT/${encoded_tls_crt}/" ./deployment/values.yaml

helm package deployment/ --destination ./charts
helm install login-service ./charts/my-app-0.1.0.tgz

perl -i -pe "s/\Q${encoded_tls_key}\E/BASE64_ENCODED_KEY/g" ./deployment/values.yaml
perl -i -pe "s/\Q${encoded_tls_crt}\E/BASE64_ENCODED_CRT/g" ./deployment/values.yaml

