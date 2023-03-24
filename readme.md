# **microk8s setup**

```sh
microk8s reset
sudo iptables -P FORWARD ACCEPT
microk8s enable dns dashboard
microk8s kubectl get ns
```

### **Reference to fix metrics server error:**

[FIX](https://stackoverflow.com/questions/71843068/metrics-server-is-currently-unable-to-handle-the-request)

```sh
kubectl edit deployments.apps -n kube-system metrics-server
```

insert:

```yaml
hostNetwork: true
```

after the `dnsPolicy: ClusterFirst`

**OR**

We can use `k9s`

## **Creating values.yaml for added configuration**

create prom-values.yaml & trivy-values.yaml

## **Creating namespace monitoring where we will install prometheus from its values.yaml**

```sh
kubectl create ns monitoring
microk8s helm upgrade --install prom prometheus-community/kube-prometheus-stack -n monitoring --values prom-values.yaml
microk8s helm install trivy-operator aqua/trivy-operator \
>   --namespace trivy-system \
>   --create-namespace \
>   --version 0.12.1 \
>   --values trivy-values.yaml
```

## **Installing Trivy Operator via Helm**

```sh
microk8s helm upgrade trivy-operator aqua/trivy-operator   --namespace trivy-system   --create-namespace   --version 0.12.1   --set serviceMonitor.enabled=true
```

## **Debugging Firewall issues**

```sh
firewall-cmd --add-port={9153/tcp,10250/tcp,9093/tcp}  --zone=docker
firewall-cmd --reload
firewall-cmd --runtime-to-permanent
```

OR

```sh
systemctl stop firewalld
```
