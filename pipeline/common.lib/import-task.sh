#!/bin/bash
# Set the context to desired namespace
kubectl config set-context --current --namespace=$3

# Create the configmap with the exported data from source trading networks
cd /applications/tradingnetworks/sourcecode/tn-assets
kubectl create configmap tn-dataload-cm --from-file=ExportedData-$1.zip --from-file=consolidated/TNImport.xml

# Modify the k8s job name with release iteration and apply the k8s job specifications 
cd ../..//manifests/jobs
sed -i "s/<TAG>/$1/" tn-assetimport-job.yaml
kubectl apply -f ../../env-manifests/$2/tn-appprop-cm.yaml -f ../tn-utilfiles-cm.yaml -f .
sleep 5

# List the k8s jobs that has been created
kubectl get jobs | grep job-asset-import-tradingnetworks-r-$1

# Tail the logs of the job that has been created
kubectl logs -f job/job-asset-import-tradingnetworks-r-$1

# Delete the configmap containing the exported data from source trading networks
kubectl delete cm tn-dataload-cm