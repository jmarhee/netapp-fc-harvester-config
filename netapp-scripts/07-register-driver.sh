#!/usr/bin/env bash
# Add csi.trident.netapp.io to csi-driver-config..
# https://documentation.suse.com/cloudnative/virtualization/v1.5/en/storage/csidriver.html
set -euo pipefail

current=$(kubectl get settings.harvesterhci.io csi-driver-config -o jsonpath='{.value}')
powermax=
if [[ "$current" == *'"csi-powermax.dellemc.com"'* ]]; then
  powermax=',"csi-powermax.dellemc.com":{"volumeSnapshotClassName":"powermax-snapclass"}'
fi

value="{\"driver.longhorn.io\":{\"volumeSnapshotClassName\":\"longhorn-snapshot\",\"backupVolumeSnapshotClassName\":\"longhorn\"}${powermax},\"csi.trident.netapp.io\":{\"volumeSnapshotClassName\":\"netapp-fcp-snapclass\"}}"

kubectl patch settings.harvesterhci.io csi-driver-config --type=merge --patch-file=/dev/stdin <<EOF
value: |-
  ${value}
EOF

echo "$value"
