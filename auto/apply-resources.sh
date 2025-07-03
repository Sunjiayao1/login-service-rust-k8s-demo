#!/bin/bash

set -euo pipefail

cd $(dirname $0)/..

eval $(minikube docker-env)

docker build -t login-api:latest .

encoded_tls_key=$(cat tls.key | base64 | tr -d '\n')
encoded_tls_crt=$(cat tls.crt | base64 | tr -d '\n')
admin_password=$(cat adminPassword)

sed -i "" "s/BASE64_ENCODED_KEY/${encoded_tls_key}/g" ./deployment/values.yaml
sed -i "" "s/BASE64_ENCODED_CRT/${encoded_tls_crt}/g" ./deployment/values.yaml
sed -i "" "s/ADMIN_PASSWORD/${admin_password}/g" ./deployment/values.yaml

helm dependency update
helm package deployment/ --destination ./charts
helm install login-service ./charts/my-app-0.1.0.tgz

echo "Prometheus and Grafana installed successfully! You can access the dashboards with:"

echo "Prometheus: http://localhost:9090"
echo "Run: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-kube-prometheus-prometheus 9090:9090"
echo "Grafana: http://localhost:3000"
POD_NAME=$(kubectl --namespace monitor get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
echo "Run: kubectl --namespace monitor port-forward $POD_NAME 3000"

perl -i -pe "s/\Q${encoded_tls_key}\E/BASE64_ENCODED_KEY/g" ./deployment/values.yaml
perl -i -pe "s/\Q${encoded_tls_crt}\E/BASE64_ENCODED_CRT/g" ./deployment/values.yaml
sed -i "" "s/${admin_password}/ADMIN_PASSWORD/g" ./deployment/values.yaml
