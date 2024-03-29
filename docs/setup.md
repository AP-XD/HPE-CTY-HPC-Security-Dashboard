# **Installation Steps**

## Project Setup

- Cloning the project repository to your local machine.
```sh
git clone https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard 
```

## microk8s Installation

1. Install MicroK8s on your machine using the following commands:

```sh
sudo zypper addrepo --refresh \
    https://download.opensuse.org/repositories/system:/snappy/openSUSE_Tumbleweed \
    snappy
sudo zypper --gpg-auto-import-keys refresh
sudo zypper dup --from snappy
sudo zypper install snapd
sudo systemctl enable --now snapd
sudo systemctl enable --now snapd.apparmor
sudo snap install microk8s --classic --channel=1.26
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
su - $USER
alias k="microk8s kubectl"
microk8s.kubectl config view --raw > $HOME/.kube/config
```

2. Start and enable MicroK8s using the following commands:

```sh
sudo -i
microk8s reset
exit
sudo iptables -P FORWARD ACCEPT
microk8s start
microk8s enable dns
k get ns
```

3. (Optional)Install k9s in OpenSUSE for monitoring and easy access of pods status

```sh
sudo zypper in k9s
```

## Configuration

1. Use the default [prom-values.yaml](../values/prom-values.yaml) file with the following content or modify it:

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    serviceMonitorNamespaceSelector: {}
```

2. Use the default [trivy-values.yaml](../values/trivy-values.yaml) file with the following content or modify it:

```yaml
serviceMonitor:
  # enabled determines whether a serviceMonitor should be deployed
  enabled: true
trivy:
  # ignoreUnfixed is the flag to show only fixed vulnerabilities in
  # vulnerabilities reported by Trivy. Set to true to enable it.
  ignoreUnfixed: true
operator:
  # metricsVulnIdEnabled is the flag to enable metrics about cve vulns id
  # be aware of metrics cardinality is significantly increased with this feature enabled.
  metricsVulnIdEnabled: true
compliance:
  # cron: this flag controls the cron interval for compliance report generation
  cron: 0 */1 * * *
  # reportType: this flag controls the type of report generated (summary or all)
  reportType: all
```

## Executing the scripts

1. Make the scripts executable

```sh
chmod +x ./scripts/update_deploy.sh
chmod +x ./scripts/metrics_update.sh
```

2. Execute the [update_deploy.sh](../scripts/update_deploy.sh) script to install Trivy Operator and Kube Prometheus Stack Helm Chart automatically using the provided configuration files in the project repository.

3. Setup CRON JOB for auto updating the metrics hourly using the [metrics_update.sh](../scripts/metrics_update.sh) script and save logs in a file

```sh
{ crontab -l; echo "0 * * * * $(pwd)/metrics_update.sh <namespace-name> >> $(pwd)/cron-log.txt "; } | crontab -
```

 If you don't want to save logs of the cronjob and only view them via mail, use the following command:

```sh
{ crontab -l; echo "0 * * * * $(pwd)/metrics_update.sh <namespace-name>"; } | crontab -
mail # Press ENTER to view mail from cronjob
```

## Setup Port Forwarding

1. Run k9s

```sh
./k9s
```
![K9s](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/1.png)


2. Enable port forwarding for the following pods by pressing Shift+F and Ok on each pod to confirm port forwarding

- `prom-grafana` pod
- `prometheus-prom-kube-prometheus-stack-prometheus` pod
- `trivy-operator` pod

Sample:
![K9s](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/2.png)


## Configure Datasources in Grafana

1. Access Grafana web UI on http://localhost:3000/ and enter admin credentials
![Grafana login](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/3.png)

2. Plugin activation
On the top left corner, click on hamburger icon and navigate to Administration > Plugins

![Grafana Plugin](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/4.png)

Now in the search bar, enter json and click 'JSON API' and install it.

![JSON API](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/5.png)

Click 'Create a JSON API Data Source'.

![JSON API DATASOURCE](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/6.png)

Get the URL from the cron-log.txt and now in the HTTP > URL field, enter <node-ip:port>.
Configure the datasource for both Kube-Bench and Trivy to fetch data from `<node-ip>:30000` and `<node-ip>:30001`.

![Cron log](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/7.png)

Click save and test. If you get a success message then the plugin is configured properly.

![JSON API](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/8.png)

## Import the Dashboard

Click on the **+** symbol on the upper right corner and select Import dashboard from there

![Add button](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/9.png)

Now a window will appear like this, prompting you to import a json file. Import [this file](../Grafana/CIS%20FINALIZED-1685428397856.json) and select the datasources appropriately and click import.

![Import json](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/10.png)

## Troubleshooting Firewall issues

1. If you encounter firewall issues, you can try the following commands to allow specific ports:

```sh
firewall-cmd --add-port={9153/tcp,10250/tcp,9093/tcp} --zone=docker
firewall-cmd --reload
firewall-cmd --runtime-to-permanent
```

OR

```sh
systemctl stop firewalld
```

OR

Stop the firewall using Yast Firewall
![Yast Firewall](https://github.com/AP-XD/HPE-CTY-HPC-Security-Dashboard/blob/c757fa1ad6e21f01bf05259f64266c9aadb0f16c/images/11.png)


Please note that these instructions assume you are using OpenSUSE and have installed MicroK8s. Some commands and steps may vary depending on your operating system and Kubernetes distribution.

Feel free to modify and improve these instructions as needed for your specific setup.
