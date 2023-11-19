#!/bin/bash
NAMESPACE="$1" # Setting the namespace from command line argument
NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]') # Converting it to lower case 
cd /mnt/SSD_D/Kubernetes/microk8s # Setting the working directory (Should be set to the path where the repo is cloned)
/snap/bin/microk8s helm uninstall kube-automate -n $NAMESPACE
/snap/bin/microk8s helm install kube-automate ./kube-automate-0.1.0.tgz -n $NAMESPACE --create-namespace         
sleep 30

/snap/bin/microk8s kubectl get clustercompliancereport cis -o=jsonpath='{.status}' | jq . > ./trivy-cis-status.json # Saving the trivy report in a file
# /snap/bin/microk8s kubectl  -n $NAMESPACE logs $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > ./kube-bench.json # Saving the kube bench report in a file
# /snap/bin/microk8s kubectl cp ./kube-bench.json $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="nodeapp")].metadata.name}'):/app/kube-bench.json -n $NAMESPACE
/snap/bin/microk8s kubectl cp ./trivy-cis-status.json $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="nodeapp")].metadata.name}'):/app/trivy-cis-status.json -n $NAMESPACE

echo "Now create two different JSON API PLUGIN Datasources and
 add these addresses in the HTTP URL field in Grafana JSON API PLUGIN
 for fetching the reports from Kube Bench and Trivy 
 Kube Bench JSON: http://$(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30000/
 Trivy Status JSON: http://$(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30001/"
