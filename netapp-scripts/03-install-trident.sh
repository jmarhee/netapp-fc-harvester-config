#!/usr/bin/env bash
# Install the Trident operator. Chart 100.2606.1 is the release tested in
# https://harvesterhci.io/kb/install_netapp_trident_csi/
# It supports Kubernetes 1.27-1.36, including RKE2 1.32 on Harvester 1.5.
# Override with TRIDENT_CHART_VERSION after checking `helm search`.
set -euo pipefail

VERSION="${TRIDENT_CHART_VERSION:-100.2606.1}"

helm repo add netapp-trident https://netapp.github.io/trident-helm-chart
helm repo update
helm search repo netapp-trident --versions | head
helm upgrade --install trident netapp-trident/trident-operator \
  --version "$VERSION" \
  --namespace trident \
  --create-namespace \
  --wait
kubectl get pods -n trident -o wide
