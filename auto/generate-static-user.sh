#!/bin/bash

set -euo pipefail

cd $(dirname $0)/..

USERNAME="user-a"
USER_GROUP="pod-reader"

mkdir -p certs

echo "Generate certificate for ${USERNAME}"

CA_PATH="${HOME}/.minikube/ca.crt"
CA_KEY_PATH="${HOME}/.minikube/ca.key"

openssl genrsa -out certs/${USERNAME}.key 2048
openssl req -new -key certs/${USERNAME}.key -out certs/${USERNAME}.csr -subj "/CN=${USERNAME}/O=${USER_GROUP}"

openssl x509 -req \
  -in certs/${USERNAME}.csr \
  -CA ${CA_PATH} \
  -CAkey ${CA_KEY_PATH} \
  -CAcreateserial \
  -out certs/${USERNAME}.crt \
  -days 30
