#!/usr/bin/env bash
# Add csi.trident.netapp.io to csi-driver-config. Uses kubectl only.
# Reads the current value and keeps a PowerMax entry when that key is already
# present. Writes the Longhorn backup class and netapp-fcp-snapclass from 05.
# Any other provisioner key in the current value is dropped.
# Output: the JSON written to the setting. It must list csi.trident.netapp.io,
# then apply 08-test-pvc.yaml.
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
echo "csi.trident.netapp.io is registered. Apply 08-test-pvc.yaml."
