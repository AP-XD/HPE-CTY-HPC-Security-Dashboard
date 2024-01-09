#!/bin/bash
NAMESPACE="$1" # Setting the namespace from command line argument
NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]') # Converting it to lower case
/snap/bin/microk8s helm uninstall kube-automate -n $NAMESPACE
/snap/bin/microk8s helm install kube-automate ./kube-automate-0.1.0.tgz -n $NAMESPACE --create-namespace         
sleep 30

/snap/bin/microk8s kubectl get clustercompliancereport cis -o=jsonpath='{.status}' | jq . > ./trivy-cis-status.json # Saving the trivy report in a file
/snap/bin/microk8s kubectl cp ./trivy-cis-status.json $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="nodeapp")].metadata.name}'):/app/trivy-cis-status.json -n $NAMESPACE

echo "Now create a JSON API PLUGIN Datasources and add these addresses in the HTTP URL field 
 of Grafana JSON API PLUGIN for fetching the CIS Benchmark report from Trivy
 Trivy Status JSON: http://$(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30001/"
