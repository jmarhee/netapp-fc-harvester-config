#!/usr/bin/env bash
# Exclude the trident namespace from deny-pod-exec, then restart the operator.
# The operator execs into trident-controller during install.
set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/rke2/rke2.yaml}"

bindings=$(kubectl get validatingadmissionpolicybinding -o json)
BINDINGS="$bindings" python3 - <<'PY'
import json, os, subprocess, sys
data = json.loads(os.environ["BINDINGS"])
found = [i for i in data.get("items", []) if i.get("spec", {}).get("policyName") == "deny-pod-exec"]
if not found:
    sys.exit("No ValidatingAdmissionPolicyBinding references policy deny-pod-exec")
for item in found:
    name = item["metadata"]["name"]
    for owner in item["metadata"].get("ownerReferences") or []:
        if owner.get("kind") == "ClusterPolicy":
            sys.exit(f"{name} is owned by Kyverno policy {owner.get('name')}. Exclude the trident namespace there instead.")
    selector = item.setdefault("spec", {}).setdefault("matchResources", {}).setdefault("namespaceSelector", {})
    exprs = selector.setdefault("matchExpressions", [])
    for expr in exprs:
        if expr.get("key") == "kubernetes.io/metadata.name" and expr.get("operator") == "NotIn":
            values = expr.setdefault("values", [])
            if "trident" not in values:
                values.append("trident")
            break
    else:
        exprs.append({
            "key": "kubernetes.io/metadata.name",
            "operator": "NotIn",
            "values": ["trident"],
        })
    patch = {"spec": {"matchResources": {"namespaceSelector": selector}}}
    subprocess.check_call([
        "kubectl", "patch", "validatingadmissionpolicybinding", name,
        "--type=merge", "-p", json.dumps(patch),
    ])
    print(f"Excluded namespace trident from {name}")
PY

kubectl rollout restart deployment/trident-operator -n trident
kubectl rollout status deployment/trident-operator -n trident
kubectl get pods -n trident
