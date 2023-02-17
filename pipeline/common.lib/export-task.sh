#!/bin/bash
kubectl config set-context --current --namespace=$2
# Modify the k8s job name with release iteration and apply the k8s job specifications 
cd applications/tradingnetworks/manifests/jobs
sed -i "s/<TAG>/$1/" tn-assetexport-job.yaml
sed -i "s/<TAG>/$1/" tn-importexportscript-cm.yaml
kubectl apply -f ../../env-manifests/$2/tn-appprop-cm.yaml -f ../../env-manifests/$2/webmethods-licenses.yaml -f ../tn-utilfiles-cm.yaml -f tn-importexportscript-cm.yaml -f tn-assetexport-job.yaml
sleep 5

echo "Describing the configurations"
kubectl describe cm tn-appprop-cm tn-importexportscript-cm webmethodslicensekeys tn-utilfiles-cm
# List the k8s jobs that has been created
kubectl get pods | grep pod-asset-export-tradingnetworks-r-$1
kubectl describe pod pod-asset-export-tradingnetworks-r-$1

kubectl wait --for=condition=ready --timeout=120s pod/pod-asset-export-tradingnetworks-r-$1

cd ../../sourcecode/tn-assets/
kubectl exec pod-asset-export-tradingnetworks-r-$1 -- bash -c "cd /opt/softwareag/IntegrationServer/packages/WmTN/bin;./tnexport.sh -bin ExportedData-$1 -all;cat /opt/softwareag/IntegrationServer/ExportedData-$1.zip" > ExportedData-$1.zip
kubectl delete po pod-asset-export-tradingnetworks-r-$1
if [ -f "ExportedData-$1.zip" ]; then
    echo "ExportedData-$1.zip exists."
    unzip ExportedData-$1.zip
    git config user.name "Jenkins"
    git config user.email "Jenkins@jenkins.com"
    git add ExportedData-$1.bin
    git commit -m "committing exported tn data"
    git push origin HEAD:develop
else 
    echo "ExportedData-$1.zip does not exist. Please verify the logs"
    exit 1
fi