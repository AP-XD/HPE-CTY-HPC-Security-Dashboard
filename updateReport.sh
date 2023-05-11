#!/bin/bash
NAMESPACE="$1"
NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]')
cd /mnt/SSD/Kubernetes/microk8s
/snap/bin/microk8s kubectl create ns $NAMESPACE 
/snap/bin/microk8s kubectl -n $NAMESPACE delete job kube-bench
/snap/bin/microk8s kubectl -n $NAMESPACE apply -f job-cis.yaml
sleep 10
/snap/bin/microk8s kubectl get compliance cis -o=jsonpath='{.status}' | jq . > trivy-cis-status.json
/snap/bin/microk8s kubectl  -n $NAMESPACE logs $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > kube-bench.json
docker login
docker build -t 952910/node-server .
docker push 952910/node-server
/snap/bin/microk8s kubectl -n $NAMESPACE delete service nodeapp-service nodeapp-service2
/snap/bin/microk8s kubectl -n $NAMESPACE delete deployment nodeapp-deployment
/snap/bin/microk8s kubectl -n $NAMESPACE apply -f node-deploy.yaml
echo "Now create two different JSON API PLUGIN Datasources and
 add these addresses in the HTTP URL field in Grafana JSON API PLUGIN
 for fetching the reports from Kube Bench and Trivy 
 Trivy Status JSON: $(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30000/
 Kube Bench JSON: $(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30001/"
