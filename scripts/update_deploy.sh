microk8s helm repo update
microk8s kubectl create ns monitoring
microk8s helm upgrade --install prom prometheus-community/kube-prometheus-stack -n monitoring --values ../values/prom-values.yaml
microk8s helm upgrade --install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --version 0.14.0-rc \
  --values ../values/trivy-values.yaml
