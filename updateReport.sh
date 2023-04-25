#!/bin/bash

while true
do
  microk8s kubectl delete job kube-bench
  microk8s kubectl apply -f job-cis.yaml
  sleep 10
  microk8s kubectl get compliance cis -o=jsonpath='{.status}' | jq . > trivy-cis-status.json
  microk8s kubectl logs $(microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > kube-bench.json
  docker build -t 952910/node-server .
  docker push 952910/node-server
  microk8s kubectl delete service nodeapp-service nodeapp-service2
  microk8s kubectl delete deployment nodeapp-deployment
  microk8s kubectl apply -f node-deploy.yaml
  sleep 3600
done