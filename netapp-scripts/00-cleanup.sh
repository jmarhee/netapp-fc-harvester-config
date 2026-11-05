#!/usr/bin/env bash
# Run as root on each Harvester node before 02-multipath.yaml.
# Does NOT require deletion of the Trident Helm release-- re-run `helm upgrade --install ...` in 03-install-trident.sh.
set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"

kubectl delete cloudinit fc-multipath --ignore-not-found
kubectl delete tridentbackendconfig -n trident ontap-fcp-backend --ignore-not-found
kubectl delete secret -n trident ontap-fcp-backend-secret --ignore-not-found
kubectl delete storageclass netapp-fcp --ignore-not-found
kubectl delete volumesnapshotclass netapp-fcp-snapclass --ignore-not-found
kubectl delete storageprofile netapp-fcp --ignore-not-found
kubectl delete pvc -n default netapp-fcp-test --ignore-not-found

rm -f /oem/99_fc_multipath.yaml /etc/multipath.conf
systemctl disable --now multipathd
