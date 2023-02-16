#!/bin/bash
kubectl config set-context --current --namespace=$3
# Deploy the environment specific configurations
cd applications/tradingnetworks/env-manifests/$2
kubectl apply -f .

# Deploy the target manifests to create the runtimes/pods
cd ../../manifests
sed -i "s/<TAG>/$1/" tn-spec-deployment.yaml
kubectl apply -f .
