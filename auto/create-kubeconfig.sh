#!/bin/bash

set -euo pipefail

cd $(dirname $0)/..

USERNAME="user-a"
CONTEXT_NAME="${USERNAME}-context"
KUBECONFIG_OUT="user-a-kubeconfig"
NAMESPACE="login-service"

CLUSTER_NAME=$(kubectl config view -o jsonpath='{.clusters[0].name}')
CLUSTER_SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
CLUSTER_CA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority}')

KUBECONFIG_TMP=./kubeconfig.tmp
kubectl config --kubeconfig=${KUBECONFIG_TMP} set-cluster ${CLUSTER_NAME} \
  --server="${CLUSTER_SERVER}" \
  --certificate-authority="${CLUSTER_CA}" \
  --embed-certs=true

kubectl config --kubeconfig=${KUBECONFIG_TMP} set-credentials ${USERNAME} \
  --client-certificate=certs/${USERNAME}.crt \
  --client-key=certs/${USERNAME}.key \
  --embed-certs=true

kubectl config --kubeconfig=${KUBECONFIG_TMP} set-context ${CONTEXT_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${USERNAME} \
  --namespace=${NAMESPACE}

kubectl config --kubeconfig=${KUBECONFIG_TMP} use-context ${CONTEXT_NAME}
mv ${KUBECONFIG_TMP} ${KUBECONFIG_OUT}
