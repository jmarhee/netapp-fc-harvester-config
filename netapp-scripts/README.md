# NetApp FC

Fibre Channel on Harvester 1.7, from [Using NetApp Storage on Harvester](https://harvesterhci.io/kb/install_netapp_trident_csi/) and the [YAML post](https://blog.5glinux.com/posts/netapp-trident-harvester-yamls/). Run these on a Harvester node. Leave `harvester-longhorn` as the default StorageClass.

| Step | File | Outcome |
| --- | --- | --- |
| Preparation | [00-cleanup.sh](00-cleanup.sh) | Run as root on each node. Old `fc-multipath` CloudInit, backend, and `/etc/multipath.conf` are gone. The Trident Helm release stays installed. |
| Prerequisite | [01-record-wwpns.sh](01-record-wwpns.sh) | WWPNs to zone to the SVM FC LIFs. |
| 1 | [02-multipath.yaml](02-multipath.yaml) | After `Present` is True, maintenance mode, reboot, disable maintenance mode, one node at a time. `multipathd` is active and does not claim local disks. |
| 2 | [03-install-trident.sh](03-install-trident.sh) | `trident-controller` and `trident-node-linux` are Running. |
| 3 | Secret, then [04-backend.yaml](04-backend.yaml) | `netapp-fc` is `Bound` / `Success`. |
| 4 | [05-storageclass.yaml](05-storageclass.yaml) | StorageClass `netapp-fc` (`sanType: fcp`) and VolumeSnapshotClass `trident-snapshotclass`. StorageProfile `status` is already filled in. |
| 5 | [06-register-driver.sh](06-register-driver.sh) | `csi-driver-config` lists `csi.trident.netapp.io` with `trident-snapshotclass`. |
| 6 | [07-test-pvc.yaml](07-test-pvc.yaml) | PVC `Bound`. Then create a VM whose root disk uses `netapp-fc`. |

Create the Secret before applying `04-backend.yaml`. Do not commit the password.

```bash
kubectl -n trident create secret generic netapp-creds \
  --from-literal=username=<ontap user> \
  --from-literal=password='<ontap password>'
```

`managementLIF` in `04-backend.yaml` is the SVM management LIF. The account is SVM-scoped `vsadmin` with `http` and `ontapi` enabled. The backend has no `svm`, `dataLIF`, `useREST`, `spaceReserve`, `snapshotReserve`, or `limitAggregateUsage`.
