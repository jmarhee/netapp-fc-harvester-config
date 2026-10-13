#!/usr/bin/env bash
# Run after 05. Waits for StorageProfile netapp-fcp, then sets block mode.
# Output: the patched profile. No error, then run 07-register-driver.sh.
# https://documentation.suse.com/cloudnative/virtualization/v1.5/en/storage/csidriver.html
set -euo pipefail

set +o pipefail
kubectl get storageprofile \
  --field-selector metadata.name=netapp-fcp \
  --watch --output=name \
  --request-timeout=60s \
  | grep -q -m1 -F 'netapp-fcp'
set -o pipefail

kubectl patch storageprofile netapp-fcp --type=merge --patch-file=/dev/stdin <<'EOF'
spec:
  claimPropertySets:
    - accessModes:
        - ReadWriteMany
        - ReadWriteOnce
      volumeMode: Block
  cloneStrategy: snapshot
  snapshotClass: netapp-fcp-snapclass
EOF
