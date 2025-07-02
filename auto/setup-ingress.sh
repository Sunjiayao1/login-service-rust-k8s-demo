#!/bin/bash

set -e pipefail

cd $(dirname $0)/..

echo "Choose Ingress Service type:"
echo "1) NodePort"
echo "2) LoadBalancer"
read -p "Enter your choice [1 or 2]: " choice

if [ "$choice" == "1" ]; then
  kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
  minikube tunnel
else
  minikube service ingress-nginx-controller -n ingress-nginx --url
fi
