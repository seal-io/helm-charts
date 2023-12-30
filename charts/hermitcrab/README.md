# Hermit Crab Chart

This chart installs the [seal-io/hermitcrab](https://github.com/seal-io/hermitcrab) application. This application comes packaged with:

- Kubernetes StatefulSet for running Hermit Crab
- Kubernetes Service for exposing Hermit Crab
- Kubernetes Persistent Volume Claim for storing Hermit Crab data
- Kubernetes Pod Disruption Budget for ensuring Hermit Crab is highly available

## Prerequisites

- Kubernetes 1.24+
- Helm 3.0.0+
- Persistent Volume provisioner support in the underlying infrastructure

## Installing

To install the chart with the release name `my-release`:

```shell
helm repo add seal-io https://seal-io.github.io/helm-charts
helm install my-release seal-io/hermitcrab --version 0.1.2
```

Also be able to install from OCI registry:

```shell
# latest version
helm install my-release oci://ghcr.io/seal-io/helm-charts/hermitcrab
# with specific version
helm install my-release oci://ghcr.io/seal-io/helm-charts/hermitcrab --version 0.1.2
```

## Uninstalling

To uninstall/delete the `my-release` deployment:

```shell
helm uninstall my-release
```

## Changelog

For full list of changes please check ArtifactHub [changelog](https://artifacthub.io/packages/helm/seal-io/hermitcrab?modal=changelog).

## Parameters

### Global parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.imageRegistry | string | `""` | Configure image registry. |
| global.imagePullSecrets | list | `[]` | Configure image pull secrets. <br/> Example: <br/> ``` imagePullSecrets: ["my-image-pull-secret-name"] ``` |
| global.storageClass | string | `""` | Configure storage class. |

### Common parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` | Partially override common.fullname template (will maintain the release name). |
| fullnameOverride | string | `""` | Fully override common.fullname template. |
| namespaceOverride | string | `""` | Partially override common.namespace. |
| commonAnnotations | object | `{}` | Additional common annotations to add to all resources. |
| commonLabels | object | `{}` | Additional common labels to add to all resources. |

### Hermit Crab parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hermitcrab.name | string | `"hermitcrab"` | Name of the Hermit Crab server. |
| hermitcrab.replicas | int | `1` | Number of Hermit Crab Pods to run. |
| hermitcrab.image.repository | string | `"sealio/hermitcrab"` | Image name. |
| hermitcrab.image.tag | string | `"v0.1.2"` | Image tag. |
| hermitcrab.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| hermitcrab.command | list | `["hermitcrab"]` | Entrypoint command. |
| hermitcrab.args | list | `["--log-debug","--log-verbosity=4"]` | Entrypoint arguments. |
| hermitcrab.env | list | `[]` | Environment variables. <br/> Example: <br/> ``` env: [{"name": "MY_ENV_VAR", "value": "my-env-var-value"}] ``` |
| hermitcrab.envFrom | list | `[]` | Environment reference variables. <br/> Example: <br/> ``` envFrom: [{"configMapRef": {"name": "my-configmap-name"}}] ``` |
| hermitcrab.resources | object | `{}` | Resource limits and requests. <br/> Example: <br/> ``` resources: {"limits": {"cpu": "2", "memory": "4Gi"}, "requests": {"cpu": "500m", "memory": "512Mi"}} ``` |
| hermitcrab.startupProbe.initialDelaySeconds | int | `0` | Startup probe initial delay. |
| hermitcrab.startupProbe.timeoutSeconds | int | `1` | Startup probe timeout. |
| hermitcrab.startupProbe.periodSeconds | int | `5` | Startup probe period. |
| hermitcrab.startupProbe.failureThreshold | int | `10` | Startup probe failure threshold. |
| hermitcrab.startupProbe.successThreshold | int | `1` | Startup probe success threshold. |
| hermitcrab.readinessProbe.enabled | bool | `true` | Enable readiness probe. |
| hermitcrab.readinessProbe.timeoutSeconds | int | `5` | Readiness probe timeout. |
| hermitcrab.readinessProbe.periodSeconds | int | `5` | Readiness probe period. |
| hermitcrab.readinessProbe.failureThreshold | int | `3` | Readiness probe failure threshold. |
| hermitcrab.readinessProbe.successThreshold | int | `1` | Readiness probe success threshold. |
| hermitcrab.livenessProbe.enabled | bool | `true` | Enable liveness probe. |
| hermitcrab.livenessProbe.timeoutSeconds | int | `5` | Liveness probe timeout. |
| hermitcrab.livenessProbe.periodSeconds | int | `5` | Liveness probe period. |
| hermitcrab.livenessProbe.failureThreshold | int | `10` | Liveness probe failure threshold. |
| hermitcrab.livenessProbe.successThreshold | int | `1` | Liveness probe success threshold. |
| hermitcrab.pdb.enabled | bool | `true` | Enable PodDisruptionBudget. |
| hermitcrab.pdb.minAvailable | int | `1` | Minimum number of Pods that must be available. |
| hermitcrab.pdb.maxUnavailable | int | `0` | Maximum number of Pods that can be unavailable. |
| hermitcrab.service.enabled | bool | `true` | Enable Service. |
| hermitcrab.service.type | string | `"ClusterIP"` | Service type. |
| hermitcrab.service.ports | object | `{"http":80,"https":443}` | Service ports. |
| hermitcrab.service.sessionAffinity | string | `"ClientIP"` | Service session affinity. |
| hermitcrab.service.sessionAffinityConfig | object | `{}` | Service session affinity config. <br/> Example: <br/> ``` sessionAffinityConfig: {"clientIP": {"timeoutSeconds": 300}} ``` |
| hermitcrab.pvc.enabled | bool | `true` | Enable PersistentVolumeClaim. |
| hermitcrab.pvc.subPath | string | `""` | PersistentVolumeClaim sub path to mount. |
| hermitcrab.pvc.storageClass | string | `""` | PersistentVolumeClaim storage class. |
| hermitcrab.pvc.accessModes | list | `["ReadWriteOnce"]` | PersistentVolumeClaim access modes. |
| hermitcrab.pvc.size | string | `"1Gi"` | PersistentVolumeClaim storage size. |
| hermitcrab.tls.enabled | bool | `true` | Enable TLS. |
| hermitcrab.tls.domainName | string | `""` | Provide a Domain Name to gain a Let's Encrypt certificate via ACME. |
| hermitcrab.tls.secretName | string | `""` | Provide the name of a "kubernetes.io/tls" Secret contains a TLS certificate and key. |
| hermitcrab.providersMirror.enabled | bool | `true` | Enable sharing the `/usr/share/terraform/providers/plugins` directory from target Container. See https://github.com/seal-io/hermitcrab. |
| hermitcrab.providersMirror.image.repository | string | `"sealio/terraform-deployer"` | Image name. |
| hermitcrab.providersMirror.image.tag | string | `"v1.5.7-seal.1"` | Image tag. |
| hermitcrab.providersMirror.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs](https://github.com/norwoodj/helm-docs)
