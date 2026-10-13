# NetApp FC

| Step | File | Outcome/Next Stage Setup |
| --- | --- | --- |
| 1 | [01-record-wwpns.sh](01-record-wwpns.sh) | WWPNs to zone. SVM name and management LIF go in 04. |
| 2 | [02-multipath.yaml](02-multipath.yaml) | `multipathd` active. Empty `multipath -ll` until 08. Then 03. |
| 3 | [03-install-trident.sh](03-install-trident.sh) | Pods Running. Then fill in and apply 04. |
| 4 | [04-backend.yaml](04-backend.yaml) | Backend `PHASE` Bound. Then 05. |
| 5 | [05-storageclass.yaml](05-storageclass.yaml) | StorageClas `netapp-fcp` and snapshot class `netapp-fcp-snapclass`. Then 06. |
| 6 | [06-storageprofile.sh](06-storageprofile.sh) | Patched StorageProfile. Then 07. |
| 7 | [07-register-driver.sh](07-register-driver.sh) | JSON lists `csi.trident.netapp.io`. Then 08. |
| 8 | [08-test-pvc.yaml](08-test-pvc.yaml) | PVC `Bound`. `multipath -ll` shows the LUN. |
