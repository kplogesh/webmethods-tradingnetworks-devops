#!/bin/bash
kubectl config set-context --current --namespace=$3
# Deploy the environment specific configurations
cd applications/tradingnetworks/env-manifests/$2
kubectl apply -f tn-appprop-cm.yaml -f tn-svc.yaml -f webmethods-license.yaml

MAJOR=`sed -n 's/^MAJOR=\(.*\)/\1/p' < ../../version.txt`
MINOR=`sed -n 's/^MINOR=\(.*\)/\1/p' < ../../version.txt`
PATCH=`sed -n 's/^PATCH=\(.*\)/\1/p' < ../../version.txt`
VERSION=v${MAJOR}.${MINOR}.${PATCH}
# Deploy the target manifests to create the runtimes/pods
cd ../../manifests
sed -i "s/<TAG>/${VERSION}/g" tn-spec-deployment.yaml

kubectl apply -f .

echo "Describing the configurations"
kubectl describe cm tn-appprop-cm webmethodslicensekeys tn-utilfiles-cm
kubectl describe deploy tradingnetworks
