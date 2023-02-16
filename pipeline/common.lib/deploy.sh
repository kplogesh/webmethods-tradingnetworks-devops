#!/bin/bash

# Deploy the environment specific configurations
cd applications/tradingnetworks/env-manifests/$2
kubectl apply -f .

# Deploy the target manifests to create the runtimes/pods
cd ../../manifests
sed -i "s/<TAG>/$1/" tn-spec-deployment.yaml
kubectl apply -f .
