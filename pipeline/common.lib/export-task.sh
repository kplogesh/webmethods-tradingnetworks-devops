#!/bin/bash
kubectl config set-context --current --namespace=$3

cd applications/tradingnetworks/manifests/jobs
# Modify the k8s job name with release iteration and apply the k8s job specifications 
VERSION=$1
sed -i "s/<TAG>/${VERSION}/g" tn-assetexport-job.yaml
sed -i "s/<TAG>/${VERSION}/g" tn-importexportscript-cm.yaml

# Apply the kubernetes specifications to create the required assets
kubectl apply -f ../../env-manifests/$2/tn-appprop-cm.yaml -f ../../env-manifests/$2/webmethods-licenses.yaml -f ../tn-utilfiles-cm.yaml -f tn-importexportscript-cm.yaml -f tn-assetexport-job.yaml

sleep 5 # Just in case 

echo "Describing the configurations"
kubectl describe cm tn-appprop-cm tn-importexportscript-cm webmethodslicensekeys tn-utilfiles-cm
# List and describe the k8s pod that has been created
kubectl get pods | grep pod-asset-export-tradingnetworks-${VERSION}
kubectl describe pod pod-asset-export-tradingnetworks-${VERSION}

# Wait for the intermediate pod to be up and running
kubectl wait --for=condition=ready --timeout=120s pod/pod-asset-export-tradingnetworks-${VERSION}

# Display the logs for the intermediate pod created
kubectl logs pod-asset-export-tradingnetworks-${VERSION}

# Execute the export script within the intermediate pod created using the exec command
cd ../../sourcecode/tn-assets/
kubectl exec pod-asset-export-tradingnetworks-${VERSION} -- bash -c "cd /opt/softwareag/IntegrationServer/packages/WmTN/bin;./tnexport.sh -bin ExportedData-${VERSION} -all;cat /opt/softwareag/IntegrationServer/ExportedData-${VERSION}.zip" > ExportedData-${VERSION}.zip

# Delete the pod as at this stage, the export job would have got completed
kubectl delete po pod-asset-export-tradingnetworks-${VERSION}
if [ -f "ExportedData-${VERSION}.zip" ]; then
    echo "ExportedData-${VERSION}.zip exists."
    unzip -o ExportedData-${VERSION}.zip #unzip the content to make it available for deployment tasks
    # Push it to repository for tagging and release. The exported data pushed to repository will be used for testing in staging environment
    git config user.name "Jenkins"
    git config user.email "Jenkins@jenkins.com"
    git add ExportedData-${VERSION}.bin
    git commit -m "committing exported tn data"
    git push origin HEAD:$4
else 
    echo "ExportedData-${VERSION}.zip does not exist. Please verify the logs"
    # If the exported zip file is not generated properly, then fail the script and verify the logs produced in above steps
    exit 1
fi