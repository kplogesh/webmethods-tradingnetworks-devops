#!/bin/bash
# Set the context to desired namespace
kubectl config set-context --current --namespace=$2

# Modify the k8s job name with release iteration and apply the k8s job specifications 
cd applications/tradingnetworks/manifests/jobs
sed -i "s/<TAG>/$1/" tn-assetexport-job.yaml
sed -i "s/<TAG>/$1/" tn-importexportscript-cm.yaml
kubectl apply -f ../../env-manifests/$2/tn-appprop-cm.yaml -f ../tn-utilfiles-cm.yaml -f .
sleep 5

# List the k8s jobs that has been created
kubectl get jobs | grep job-asset-export-tradingnetworks-r-$1
kubectl describe job job-asset-export-tradingnetworks-r-$1
# Tail the logs of the job that has been created
kubectl logs -f job/job-asset-import-tradingnetworks-r-$1

# Execute the export task by using the source pod where trading networks is deployed
kubectl exec deploy/tradingnetworks -- bash -c "cd /opt/softwareag/IntegrationServer/packages/WmTN/bin;./tnexport.sh -bin ExportedData -all;cat /opt/softwareag/IntegrationServer/ExportedData.zip" > ExportedData-$1.zip                   
