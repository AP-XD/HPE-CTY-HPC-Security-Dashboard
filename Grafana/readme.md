## **List of Grafana dashboards available for Trivy Operator**

- [Trivy Operator Dashboard](https://grafana.com/grafana/dashboards/17813-trivy-operator-dashboard/)
- [Trivy Operator / Image Vulnerability](https://grafana.com/grafana/dashboards/17214-trivy-operator-image-vulnerability/)
- [Trivy Operator Reports](https://grafana.com/grafana/dashboards/16652-trivy-operator-reports/)
- [Trivy Image Vulnerability Overview](https://grafana.com/grafana/dashboards/16742-trivy-image-vulnerability-overview/)

## **Fixing Grafana Dashboard queries**

Out of these 4 we need ` Trivy Operator / Image Vulnerability ` and ` Trivy Operator Dashboard ` mainly for visualizations.
But in ` Trivy Operator / Image Vulnerability ` the namespace and cluster queries are incorrect which has been fixed in the file in this directory by modifying those query values to correct ones.

## **Fixing Image of CVE**

But now we can see that the CVEs are not showing.
Upon taking a keen look I found out that it is because vulnerability ID field can't be fetched since its disabled by default in Trivy-operator so we need to change the environment var ` OPERATOR_METRICS_VULN_ID_ENABLED ` from `false` to `true`

```yaml
- name: OPERATOR_METRICS_VULN_ID_ENABLED
          value: "true"
```

which can be done by editing the trivy operator file from `k9s`.
