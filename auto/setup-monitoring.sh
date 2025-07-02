#!/bin/bash

set -e

NAMESPACE="monitor"
RELEASE_NAME="prometheus"
ADMINPASSWORD=$(cat adminPassword)

echo "Adding prometheus-community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

echo "Installing kube-prometheus-stack in namespace '$NAMESPACE'..."
helm upgrade --install $RELEASE_NAME prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --create-namespace \
  --set grafana.adminPassword="$ADMINPASSWORD" \
  --wait

echo "Prometheus and Grafana installed successfully! You can access the dashboards with:"

echo "Prometheus: http://localhost:9090"
echo "Run: kubectl port-forward -n $NAMESPACE svc/$RELEASE_NAME-kube-prometheus-prometheus 9090:9090"
echo "Grafana: http://localhost:3000"
POD_NAME=$(kubectl --namespace monitor get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
echo "Run: kubectl --namespace monitor port-forward $POD_NAME 3000"
