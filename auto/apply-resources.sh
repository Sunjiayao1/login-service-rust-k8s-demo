#!/bin/bash

set -euo pipefail

cd $(dirname $0)/..

eval $(minikube docker-env)

docker build -t login-api:latest .

ENCODED_TLS_KEY=$(cat tls.key | base64 | tr -d '\n')
ENCODED_TLS_CRT=$(cat tls.crt | base64 | tr -d '\n')
GRAFANA_ADMIN_PASSWORD=$(cat adminPassword)

LOGIN_CHART_DIR="deployment/login-service"
MONITOR_CHART_DIR="deployment/monitor"

echo "[1/2] Deploy login-service to login-service namespace ..."

helm dependency update "${LOGIN_CHART_DIR}"
helm upgrade --install login-service "${LOGIN_CHART_DIR}" \
  -n login-service \
  --create-namespace \
  -f "${LOGIN_CHART_DIR}/values.yaml" \
  --set secret.tls.crt="${ENCODED_TLS_CRT}" \
  --set secret.tls.key="${ENCODED_TLS_KEY}"

echo "Finish deploy login-service ✅"

echo "[2/2] Deploy monitor to monitor namespace ..."

helm dependency update "${MONITOR_CHART_DIR}"
helm upgrade --install monitor "${MONITOR_CHART_DIR}" \
  -n monitor \
  --create-namespace \
  -f "${MONITOR_CHART_DIR}/values.yaml" \
  --set kube-prometheus-stack.grafana.adminPassword="${GRAFANA_ADMIN_PASSWORD}"

echo "Finish deploy monitor ✅"
