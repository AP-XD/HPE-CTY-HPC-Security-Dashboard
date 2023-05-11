#!/bin/bash

read -p "Enter the namespace: " NAMESPACE
NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]')
kubectl create ns $NAMESPACE 
microk8s kubectl -n $NAMESPACE delete job kube-bench
microk8s kubectl -n $NAMESPACE apply -f job-cis.yaml
sleep 10
microk8s kubectl get compliance cis -o=jsonpath='{.status}' | jq . > trivy-cis-status.json
microk8s kubectl  -n $NAMESPACE logs $(microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > kube-bench.json
docker login
docker build -t 952910/node-server .
docker push 952910/node-server
microk8s kubectl -n $NAMESPACE delete service nodeapp-service nodeapp-service2
microk8s kubectl -n $NAMESPACE delete deployment nodeapp-deployment
microk8s kubectl -n $NAMESPACE apply -f node-deploy.yaml
echo "Now create two different JSON API PLUGIN Datasources and
 add these addresses in the HTTP URL field in Grafana JSON API PLUGIN
 for fetching the reports from Kube Bench and Trivy 
 Trivy Status JSON: $(microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30000/
 Kube Bench JSON: $(microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30001/"
 