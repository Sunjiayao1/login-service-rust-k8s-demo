#!/usr/bin/env sh

set -euo pipefail

cd $(dirname $0)/..

kubectl patch svc ingress-nginx-controller -n ingress-nginx -p '{"spec": {"type": "LoadBalancer"}}'
minikube tunnel

# or
# minikube service ingress-nginx-controller -n ingress-nginx --url
