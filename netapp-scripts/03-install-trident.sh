#!/usr/bin/env bash
# Install the Trident operator on a Harvester 1.7 node. Chart 100.2606.1 is the
# release tested in https://harvesterhci.io/kb/install_netapp_trident_csi/
# and https://blog.5glinux.com/posts/netapp-trident-harvester-yamls/
# It supports Kubernetes 1.27-1.36. Override with TRIDENT_CHART_VERSION.
set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"

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
