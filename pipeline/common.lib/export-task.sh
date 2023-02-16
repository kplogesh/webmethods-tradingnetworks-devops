#!/bin/bash
# Modify the k8s job name with release iteration and apply the k8s job specifications 
cd applications/tradingnetworks/manifests/jobs
sed -i "s/<TAG>/$1/" tn-assetexport-job.yaml
sed -i "s/<TAG>/$1/" tn-importexportscript-cm.yaml
kubectl apply -f ../../env-manifests/$2/tn-appprop-cm.yaml -f ../../env-manifests/$2/webmethods-licenses.yaml -f ../tn-utilfiles-cm.yaml -f tn-importexportscript-cm.yaml -f tn-assetexport-job.yaml
sleep 5

# List the k8s jobs that has been created
kubectl get pods | grep pod-asset-export-tradingnetworks-r-$1
kubectl describe pod pod-asset-export-tradingnetworks-r-$1

kubectl wait --for=condition=ready --timeout=120s pod/pod-asset-export-tradingnetworks-r-$1

filename=/applications/tradingnetworks/sourcecode/tn-assets/ExportedData-$1.zip
kubectl exec pod-asset-export-tradingnetworks-r-$1 -- bash -c "cd /opt/softwareag/IntegrationServer/packages/WmTN/bin;./tnexport.sh -bin ExportedData-$1 -all;cat /opt/softwareag/IntegrationServer/ExportedData-$1.zip" > $filename

if [ -f "$filename" ]; then
    echo "$filename exists."
    kubectl delete po pod-asset-export-tradingnetworks-r-$1
    pipeline/common.lib/send-github.sh $1 $3
else 
    echo "$filename does not exist. Please verify the logs"
    exit 1
fi