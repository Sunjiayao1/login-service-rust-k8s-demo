# Rust + Kubernetes + Ingress + TLS + Helm (Basic Auth Demo)

This is a **minimal working demo** of deploying a Rust-based Basic Auth HTTP API to **Kubernetes** with **TLS**, using **Minikube** , **Helm** and **Ingress**.

If you have any questions while running this demo, feel free to check out the guide:
[All about login service rust k8s demo](https://github.com/Sunjiayao1/Blogs/blob/main/3-EN-All%20about%20login%20service%20rust%20k8s%20demo.md)

For additional questions, feel free to contact me — happy to support! 🙌

## Features

- Rust HTTP server with Basic Authentication
- Kubernetes + Helm Deployment
- Ingress + TLS (self-signed)
- HTTPS access via `https://rust.local`
- Local development via Minikube

## Getting Started

### 1. Start Minikube

```bash
minikube start
minikube addons enable ingress
```

### 2. Create Self-signed TLS Cert

Note: do not use this for public-facing services

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=rust.local/O=rust.local"
```

### 3. Add `rust.local` to `/etc/hosts`

```bash
echo "127.0.0.1 rust.local" | sudo tee -a /etc/hosts
```

### 4. Create login-service by `./auto/apply-resources.sh`

This includes:
1. Point your shell to use minikube Docker-demon by `eval $(minikube docker-env)`
2. Build image for your service `docker build -t login-service:latest .`
3. replace all sensitive data `sed -i `
4. package deployment to charts
5. deploy using helm

After deployment, you will get two pods, one deployment, one tls secret, one clusterIP and one ingress. You can check them using the following commands:

```bash
kubectl get service -n login-service
```
```
NAME                               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
service/login-service-cluster      ClusterIP   10.104.115.242   <none>        80/TCP      11h
```

```bash
kubectl get ingress -n login-service
```
```
NAME                    CLASS   HOSTS        ADDRESS               PORTS     AGE
login-service-ingress   nginx   rust.local                        80, 443   3m12s
```

### 4. Setup Ingress by `./auto/setup-ingress.sh`

This includes:
1. change ingress-nginx controller type to `LoadBalancer`
2. `minikube tunnel` creates a route to the `LoadBalaner` service (this requires privilege access)

Or directly enable high port forwarding by `minikube service ingress-nginx-controller -n ingress-nginx --url`

You will see two urls, one for port 80, and one for port 443
```
http://127.0.0.1:<high port for 80>
http://127.0.0.1:<high port for 443>
```

### 5. Access API

For healthz endpoint:
```bash
curl -k https://rust.local:<high port>/healthz # for high port
curl -k https://rust.local/healthz   # for minikube tunnel
```
For authorization endpoint:
```shell
curl -k -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization:Basic dXNlcm5hbWU6cGFzc3dvcmQ=" https://rust.local:<high port for 443>/auth # for high port
curl -k -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization:Basic dXNlcm5hbWU6cGFzc3dvcmQ=" https://rust.local/auth # for minikube tunnel
```

### 6. Monitor

Access Prometheus through: http://localhost:9090"
```shell
kubectl get svc -l app=kube-prometheus-stack-prometheus -n monitor -o jsonpath="{.items[0].metadata.name}"  # get service name
kubectl port-forward -n monitor svc/<service-name> 9090:9090" 
```
Access Grafana through: http://localhost:3000"
```shell
kubectl --namespace monitor get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname # get pod name
kubectl --namespace monitor port-forward <POD_NAME> 3000
```

### 7. Simulating a Static TLS User with limited resources access

1. Generate a Private Key and CSR for user-a, then sign the CSR with Kubernetes's CA in `generate-static-user.sh`
2. create kubeconfig for user-a
3. test with `user-a-kubeconfig`
```shell
KUBECONFIG=./user-a-kubeconfig kubectl get pods -n login-service # successfully get pods
KUBECONFIG=./user-a-kubeconfig kubectl delete pod <pod-name> -n login-service  # cannot delete
```
[image](images/7-1.png)


## TODO
- Use cert-manager + Encrypt instead of self-signed cert
- Deploy to AWS/GCP
- Create createUser endpoint to save user and password inside a DB

## Ref
- https://kubernetes.github.io/ingress-nginx/deploy/
- https://github.com/kubernetes/ingress-nginx
- https://medium.com/@tranquochuyqn93/kubernetes-tutorial-part-5-setting-up-ingress-on-minikube-with-nginx-ingress-controller-93732f9ce548
- https://bazelbuild.github.io/rules_rust/#setup


## License
MIT
