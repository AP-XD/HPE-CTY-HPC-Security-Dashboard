#!/bin/bash
NAMESPACE="$1" # Setting the namespace from command line argument
NAMESPACE=$(echo "$NAMESPACE" | tr '[:upper:]' '[:lower:]') # Converting it to lower case 
# cd /mnt/SSD/Kubernetes/microk8s # Setting the working directory (Should be set to the path where the repo is cloned)
/snap/bin/microk8s kubectl create ns $NAMESPACE # Creating the namespace
/snap/bin/microk8s kubectl -n $NAMESPACE delete job kube-bench
/snap/bin/microk8s kubectl -n $NAMESPACE apply -f job-cis.yaml # Creating the job for kube bench cis-1.20
sleep 10
/snap/bin/microk8s kubectl get compliance cis -o=jsonpath='{.status}' | jq . > trivy-cis-status.json # Saving the trivy report in a file
/snap/bin/microk8s kubectl  -n $NAMESPACE logs $(/snap/bin/microk8s kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.metadata.labels.app=="kube-bench")].metadata.name}') | jq . > kube-bench.json # Saving the kube bench report in a file
sudo docker login # Login to Docker
sudo docker build -t 952910/node-server . # Build Docker image
sudo docker push 952910/node-server # push the Docker image
/snap/bin/microk8s kubectl -n $NAMESPACE delete service nodeapp-service nodeapp-service2
/snap/bin/microk8s kubectl -n $NAMESPACE delete deployment nodeapp-deployment
/snap/bin/microk8s kubectl -n $NAMESPACE apply -f node-deploy.yaml # Create the deployment for node js server and its services
echo "Now create two different JSON API PLUGIN Datasources and
 add these addresses in the HTTP URL field in Grafana JSON API PLUGIN
 for fetching the reports from Kube Bench and Trivy 
 Kube Bench JSON: http://$(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30000/
 Trivy Status JSON: http://$(/snap/bin/microk8s kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'):30001/"
