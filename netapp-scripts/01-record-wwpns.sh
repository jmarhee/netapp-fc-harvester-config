#!/usr/bin/env bash
# Run on each node that will attach LUNs. Skip a witness.
# Retrieve initiator WWPNs from Linux sysfs (fc_host port_name). Zone them to
# the SVM FC LIF WWPNs. 
# SVM name and management LIF are not in this output. Look them up on ONTAP
# and put them in 04-backend.yaml.
# https://docs.netapp.com/us-en/trident-2506/trident-use/worker-node-prep.html
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
echo "Zone these WWPNs to the SVM FC LIFs, then put SVM_NAME and MANAGEMENT_LIF in 04-backend.yaml."
