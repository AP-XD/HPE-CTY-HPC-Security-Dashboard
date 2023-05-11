# **VISUALIZING CIS BENCHMARKS AND VULNERABILITIES IN KUBERNETES USING TRIVY & KUBE-BENCH IN GRAFANA**

## **microk8s Installation**

```sh
sudo zypper addrepo --refresh \
    https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed \
    snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install snapd
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
sudo snap install microk8s --classic --channel=1.27
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
su - $USER
alias k="microk8s kubectl"
```

## **microk8s setup**

```sh
sudo -i
microk8s reset
exit
sudo iptables -P FORWARD ACCEPT
microk8s start
microk8s enable dns
k get ns
```

## **Install k9s in OpenSUSE for monitoring and easy access of pods status**

```sh
sudo zypper in k9s
```

## **Creating values.yaml for added configuration in Trivy Operator & Kube Prometheus Stack Helm Chart**

- prom-values.yaml

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    serviceMonitorNamespaceSelector: {}
```

- trivy-values.yaml

```yaml
serviceMonitor:
  # enabled determines whether a serviceMonitor should be deployed
  enabled: true
trivy:
  # ignoreUnfixed is the flag to show only fixed vulnerabilities in
  # vulnerabilities reported by Trivy. Set to true to enable it.
  ignoreUnfixed: true
operator:
  # metricsVulnIdEnabled the flag to enable metrics about cve vulns id
  # be aware of metrics cardinality is significantly increased with this feature enabled.
  metricsVulnIdEnabled: true
compliance:
  # cron this flag control the cron interval for compliance report generation
  cron: 0 */1 * * *
  # reportType this flag control the type of report generated (summary or all)
  reportType: all
```

## **Creating namespace monitoring where we will install prometheus from its values.yaml**

```sh
microk8s helm repo update
k create ns monitoring
microk8s helm install prom prometheus-community/kube-prometheus-stack -n monitoring --values prom-values.yaml
microk8s helm install trivy-operator aqua/trivy-operator \
  --namespace trivy-system \
  --create-namespace \
  --version 0.13.2 \
  --values trivy-values.yaml
```

## **Create Deployment and Service for generating report from Kube-bench**

```sh
k delete job kube-bench
k apply -f job-cis.yaml
```

## **Saving the reports to a json file which will be served as metrics**

```sh
k get compliance cis  -o=jsonpath='{.status}' | jq . > trivy-cis-status.json
k logs $(k get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > kube-bench.json
```

## **Run the Dockerfile to update the image with the new results**

```sh
docker login
docker build -t 952910/node-server .
docker push 952910/node-server
```

## **Create Deployment and Service for serving report metrics from Kube-bench and Trivy**

```sh
k delete deployment nodeapp-deployment
k apply -f node-deploy.yaml
```

## **Open k9s and enable portforwards**

- For prom-grafana pod, prometheus-prom-kube-prometheus-stack-prometheus and trivy-operator

- Press Shift+F on each of the pods to confirm port forwarding

```sh
./k9s
```

OR

```sh
k port-forward service/prom-kube-prometheus-stack-prometheus -n monitoring 9090:9090
k port-forward service/prom-grafana -n monitoring 3000:80
```

- Run the following command to remove the headless setting `clusterIP: None` by editing trivy-operator service:

```sh
k edit service trivy-operator -n trivy-system
k port-forward service/trivy-operator -n trivy-system 8080:80
```

## **Import the Dashboards as needed and configure the datasource**

- Goto Settings and select plugins and add JSON API Plugin from there
- Now Configure the JSON API datasource for both kube-bench and trivy to fetch data from <node ip>:30000 and <node ip>:30001
- Import the dashboard configure it with the datasources

## **Script to Auto Update the metrics report**

- Finally execute this command in the root directory of this repo to update the reports from kube bench and trivy every hour using cronjob
- It will run the whole process once every 1 hr and display the logs in cron-log.txt

```sh
chmod +x ./updateReport.sh
{ crontab -l; echo "0 * * * * $(pwd)/updateReport.sh <namespace-name> >> $(pwd)/cron-log.txt "; } | crontab -
```

- If you dont want to save logs of cronjob and view it only via mail we can use

```sh
chmod +x ./updateReport.sh
{ crontab -l; echo "0 * * * * $(pwd)/updateReport.sh <namespace-name>"; } | crontab -
mail # Press ENTER to view mail from cronjob
```

## **Troubleshooting Firewall issues**

```sh
firewall-cmd --add-port={9153/tcp,10250/tcp,9093/tcp}  --zone=docker
firewall-cmd --reload
firewall-cmd --runtime-to-permanent
```

OR

```sh
systemctl stop firewalld
```
