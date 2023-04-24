## **List of Grafana dashboards available for Trivy Operator**

- **CIS FINALIZED** - From Scratch by @AP_XD
- [Trivy Operator Dashboard](https://grafana.com/grafana/dashboards/17813-trivy-operator-dashboard/)
- [Trivy Operator / Image Vulnerability](https://grafana.com/grafana/dashboards/17214-trivy-operator-image-vulnerability/)
- [Trivy Operator Reports](https://grafana.com/grafana/dashboards/16652-trivy-operator-reports/)
- [Trivy Image Vulnerability Overview](https://grafana.com/grafana/dashboards/16742-trivy-image-vulnerability-overview/)

## **Fixing Grafana Dashboard queries**

- CIS FINALIZED is the main dashboard which collects metrics from kube-bench and trivy to display the CIS Benchmarks and is a major outcome of this project
- Out of these 4 we need ` Trivy Operator / Image Vulnerability ` and ` Trivy Operator Dashboard ` mainly for visualizations.
- But in ` Trivy Operator / Image Vulnerability ` the namespace and cluster queries are incorrect which has been fixed in the file in this directory by modifying those query values to correct ones.