#!/usr/bin/env bash
# Install Trident 25.06.0. 
# https://docs.netapp.com/us-en/trident-2506/trident-get-started/kubernetes-deploy-helm.html
set -euo pipefail

helm repo add netapp-trident https://netapp.github.io/trident-helm-chart
helm repo update
helm upgrade --install trident netapp-trident/trident-operator \
  --version 100.2506.0 \
  --namespace trident \
  --create-namespace
kubectl get pods -n trident
echo " Verify: `kubectl get pods -n trident -w` until all Pods reach Running state."
