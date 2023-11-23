microk8s helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
microk8s helm repo add aqua https://aquasecurity.github.io/helm-charts/
microk8s helm repo update
microk8s kubectl create ns monitoring
microk8s kubectl delete ns trivy-system
microk8s helm upgrade --install prom prometheus-community/kube-prometheus-stack -n monitoring --values ./values/prom-values.yaml
microk8s helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --version 0.19.0-rc \
  --values ./values/trivy-values.yaml
