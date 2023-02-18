#!/bin/bash
kubectl config set-context --current --namespace=$3
# Create the configmap with the exported data from source trading networks
cd applications/tradingnetworks/sourcecode/tn-assets
VERSION=$1
# Modify the k8s job name with release iteration and apply the k8s job specifications 
sed -i "s/<TAG>/${VERSION}/g" ../../manifests/jobs/tn-assetimport-job.yaml
sed -i "s/<TAG>/${VERSION}/g" ../../manifests/jobs/tn-importexportscript-cm.yaml
sed -i "s/<TAG>/${VERSION}/g" consolidated/TNImport.xml

kubectl create configmap tn-dataload-cm --from-file=consolidated/TNImport.xml
kubectl apply -f ../../env-manifests/$2/tn-job-appprop-cm.yaml -f ../../manifests/tn-utilfiles-cm.yaml -f ../../env-manifests/$2/webmethods-licenses.yaml -f ../../manifests/jobs/tn-importexportscript-cm.yaml -f ../../manifests/jobs/tn-assetimport-job.yaml

echo "Describing the configurations"
kubectl describe cm tn-appprop-cm tn-importexportscript-cm webmethodslicensekeys tn-utilfiles-cm

# List the k8s jobs that has been created
kubectl get jobs | grep job-asset-import-tradingnetworks-${VERSION}

echo "Waiting for the job to get completed"
# Wait for the intermediate pod to be up and running
kubectl wait --for=condition=complete --timeout=180s job/job-asset-import-tradingnetworks-${VERSION}

# Tail the logs of the job that has been created
kubectl logs job/job-asset-import-tradingnetworks-${VERSION}

# Delete the configmap containing the exported data from source trading networks
kubectl delete cm tn-dataload-cm tn-job-appprop-cm
kubectl delete job job-asset-import-tradingnetworks-${VERSION}