#!/usr/bin/env bash
# Add csi.trident.netapp.io to csi-driver-config without dropping other provisioners.
# Backup Volume Snapshot Class Name stays empty. VM backups stay on Longhorn.
# https://harvesterhci.io/kb/install_netapp_trident_csi/
set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"

current=$(kubectl get settings.harvesterhci.io csi-driver-config -o jsonpath='{.value}')

value=$(CURRENT="$current" python3 - <<'PY'
import json, os
raw = os.environ.get("CURRENT", "").strip()
if not raw:
    raise SystemExit("csi-driver-config has an empty value; refusing to replace it")
data = json.loads(raw)
if not isinstance(data, dict) or "driver.longhorn.io" not in data:
    raise SystemExit("refusing to write csi-driver-config without driver.longhorn.io")
data["csi.trident.netapp.io"] = {
    "volumeSnapshotClassName": "trident-snapshotclass",
    "backupVolumeSnapshotClassName": "",
}
print(json.dumps(data, separators=(",", ":")))
PY
)

kubectl patch settings.harvesterhci.io csi-driver-config --type=merge --patch-file=/dev/stdin <<EOF
value: |-
  ${value}
EOF

echo "$value"
