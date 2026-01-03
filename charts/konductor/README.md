# konductor

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Kubernetes operator for synchronization primitives

🌐 **[Project Page](https://logiciq.ca/konductor)**

**Homepage:** <https://github.com/logicIQ/konductor>

## Source Code

* <https://github.com/logicIQ/konductor>

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm repo add logiciq https://logiciq.github.io/helm-charts
helm repo update
helm install my-release logiciq/konductor
```

### Azure Integration

For Azure integration, you can configure the chart with Azure credentials:

```bash
# With managed identity (AKS)
helm install my-release logiciq/konductor \
  --set azure.enabled=true \
  --set azure.tenantId=00000000-0000-0000-0000-000000000000 \
  --set serviceAccount.annotations."azure\.workload\.identity/client-id"=00000000-0000-0000-0000-000000000000

# With service principal
helm install my-release logiciq/konductor \
  --set azure.enabled=true \
  --set azure.tenantId=00000000-0000-0000-0000-000000000000 \
  --set azure.credentials.useManagedIdentity=false \
  --set azure.credentials.clientId=00000000-0000-0000-0000-000000000000 \
  --set azure.credentials.clientSecret=your-client-secret
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the konductor chart and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| azure.credentials.clientId | string | `""` | Azure client ID (not recommended, use managed identity instead). |
| azure.credentials.clientSecret | string | `""` | Azure client secret (not recommended, use managed identity instead). |
| azure.credentials.existingSecret | string | `""` | Name of existing secret containing Azure credentials. |
| azure.credentials.existingSecretKey | string | `"client-secret"` | Key in the existing secret for Azure client secret. |
| azure.credentials.useManagedIdentity | bool | `true` | Use managed identity for Azure credentials (recommended for AKS). |
| azure.enabled | bool | `false` | Enable Azure integration. |
| azure.tenantId | string | `""` | Azure tenant ID. |
| controller.affinity | object | `{}` | Affinity for controller deployment. |
| controller.annotations | object | `{}` | Annotations to be added to controller deployment. |
| controller.args.additionalArgs | list | `[]` | Specify additional args. |
| controller.args.healthProbeBindAddress | string | `":8081"` | Health probe endpoint address. |
| controller.args.leaderElect | bool | `false` | Enable leader election. |
| controller.args.logLevel | string | `"info"` | Log level: debug, info, warn, error. |
| controller.args.metricsBindAddress | string | `":8080"` | Metrics endpoint address. |
| controller.nodeSelector | object | `{}` | Map of key-value pairs for scheduling pods on specific nodes. |
| controller.podAnnotations | object | `{}` | Annotations to be added to controller pods. |
| controller.podLabels | object | `{}` | Pod labels to be added to controller pods. |
| controller.podSecurityContext | object | `{"runAsNonRoot":true}` | Security Context to be applied to the controller pods. |
| controller.priorityClassName | string | `""` | Priority class name to be applied to the controller pods. |
| controller.replicas | int | `1` | Specify the number of replicas of the controller Pod. |
| controller.resources | object | `{"limits":{"cpu":"500m","memory":"128Mi"},"requests":{"cpu":"10m","memory":"64Mi"}}` | Specify resources. |
| controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | Security Context to be applied to the controller container within controller pods. |
| controller.terminationGracePeriodSeconds | int | `10` | Specify terminationGracePeriodSeconds. |
| controller.tolerations | list | `[]` | Ensure pods are not scheduled on inappropriate nodes. |
| crd.install | bool | `true` | Install the Konductor CRDs. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | konductor image pullPolicy. |
| image.pullSecrets | list | `[]` | Image pull secrets for private registries. |
| image.repository | string | `"logiciq/konductor"` | konductor image repository to use. |
| image.tag | string | `nil` | konductor image tag to use. |
| nameOverride | string | `""` |  |
| podMonitor.additionalLabels | object | `{}` | Additional labels that can be used so PodMonitor will be discovered by Prometheus. |
| podMonitor.enabled | bool | `false` | If true, creates a Prometheus Operator PodMonitor. |
| podMonitor.interval | string | `""` | Interval that Prometheus scrapes metrics. |
| podMonitor.metricRelabelings | list | `[]` | MetricRelabelConfigs to apply to samples before ingestion. |
| podMonitor.namespace | string | `""` | Namespace which Prometheus is running in. |
| podMonitor.relabelings | list | `[]` | RelabelConfigs to apply to samples before scraping. |
| podMonitor.scheme | string | `"http"` | Scheme to use for scraping. |
| podMonitor.scrapeTimeout | string | `""` | The timeout after which the scrape is ended |
| serviceAccount.annotations | object | `{}` | Annotations to be added to the service account (e.g., for Azure workload identity). |
| serviceAccount.automountServiceAccountToken | bool | `true` | Controls the automatic mounting of ServiceAccount API credentials. |
| serviceAccount.enabled | bool | `true` | Creates a ServiceAccount for the controller deployment. |

## Synchronization Primitives

### Semaphore
Controls concurrent access to resources with a limited number of permits.

```yaml
apiVersion: sync.konductor.io/v1
kind: Semaphore
metadata:
  name: my-semaphore
spec:
  permits: 3
  ttl: "5m"
```

### Barrier
Synchronizes multiple pods/jobs to wait for each other before proceeding.

```yaml
apiVersion: sync.konductor.io/v1
kind: Barrier
metadata:
  name: my-barrier
spec:
  expected: 5
  timeout: "10m"
```

### Lease
Provides exclusive access to a resource with automatic expiration.

```yaml
apiVersion: sync.konductor.io/v1
kind: Lease
metadata:
  name: my-lease
spec:
  ttl: "5m"
  priority: 1
```

### Gate
Waits for multiple conditions to be met before opening.

```yaml
apiVersion: sync.konductor.io/v1
kind: Gate
metadata:
  name: my-gate
spec:
  conditions:
  - type: Job
    name: preprocessing-job
    state: Complete
  - type: Semaphore
    name: resource-semaphore
    state: Available
    value: 2
  timeout: "15m"
```