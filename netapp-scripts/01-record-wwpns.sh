#!/usr/bin/env bash
# Run on each node that will attach LUNs. Skip a witness.
# Zone these WWPNs to the SVM FC LIF WWPNs, and confirm the initiators log in
# before installing Trident.
# https://harvesterhci.io/kb/install_netapp_trident_csi/
set -euo pipefail

shopt -s nullglob
ports=(/sys/class/fc_host/host*/port_name)
if ((${#ports[@]} == 0)); then
  echo "No FC HBA port_name under /sys/class/fc_host on $(hostname)." >&2
  exit 1
fi

echo "Node: $(hostname)"
for port in "${ports[@]}"; do
  host=$(basename "$(dirname "$port")")
  echo "$host $(cat "$port")"
done
echo "Zone these WWPNs to the SVM FC LIFs. The backend uses the SVM management LIF, not the SVM name."
