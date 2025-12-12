# pvc-chonker

A cloud-agnostic Kubernetes operator for automatic PVC expansion. Works with any CSI-compatible storage without external dependencies.

## Features

- **Cloud Agnostic**: Works with any CSI-compatible storage
- **No External Dependencies**: Self-contained operation without external databases
- **Annotation-Based**: Simple configuration through Kubernetes annotations
- **Cooldown Protection**: Prevents rapid successive expansions
- **Resize Safety**: Checks for ongoing resize operations
- **Configurable Defaults**: Global settings via flags/env vars with per-PVC overrides

## Installation

### Add Helm Repository

```bash
helm repo add logiciq https://logiciq.github.io/helm-charts
helm repo update
```

### Install Chart

```bash
helm install pvc-chonker logiciq/pvc-chonker
```

### Install with Custom Values

```bash
helm install pvc-chonker logiciq/pvc-chonker \
  --set controller.args.defaultThreshold=85 \
  --set controller.args.defaultIncrease=20% \
  --set controller.args.watchInterval=10m
```

## Configuration

The following table lists the configurable parameters and their default values.

### Controller Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `controller.replicas` | Number of controller replicas | `1` |
| `controller.args.metricsBindAddress` | Metrics endpoint address | `:8080` |
| `controller.args.healthProbeBindAddress` | Health probe endpoint address | `:8081` |
| `controller.args.leaderElect` | Enable leader election | `false` |
| `controller.args.kubeletUrl` | Custom kubelet metrics URL | `""` |
| `controller.args.watchInterval` | Interval for checking PVC usage | `5m` |
| `controller.args.defaultThreshold` | Default storage threshold percentage | `80` |
| `controller.args.defaultIncrease` | Default expansion amount | `10%` |
| `controller.args.defaultCooldown` | Default cooldown period | `15m` |
| `controller.args.defaultMinScaleUp` | Default minimum scale-up amount | `1Gi` |
| `controller.args.defaultMaxSize` | Default maximum size limit | `""` |
| `controller.args.dryRun` | Enable dry run mode | `false` |
| `controller.args.logFormat` | Log format (json/console) | `json` |
| `controller.args.logLevel` | Log level | `info` |
| `controller.args.maxParallel` | Maximum parallel PVC operations | `4` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Image repository | `ghcr.io/logiciq/pvc-chonker` |
| `image.tag` | Image tag | `Chart.AppVersion` |
| `image.pullPolicy` | Image pull policy | `""` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `controller.resources.requests.cpu` | CPU request | `100m` |
| `controller.resources.requests.memory` | Memory request | `64Mi` |
| `controller.resources.limits.cpu` | CPU limit | `500m` |
| `controller.resources.limits.memory` | Memory limit | `128Mi` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `controller.podSecurityContext.runAsNonRoot` | Run as non-root user | `true` |
| `controller.podSecurityContext.runAsUser` | User ID | `65532` |
| `controller.podSecurityContext.fsGroup` | File system group | `65532` |
| `controller.securityContext.allowPrivilegeEscalation` | Allow privilege escalation | `false` |
| `controller.securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `true` |

### Monitoring Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podMonitor.enabled` | Enable Prometheus PodMonitor | `false` |
| `podMonitor.scheme` | Scraping scheme | `http` |
| `podMonitor.interval` | Scraping interval | `""` |
| `podMonitor.additionalLabels` | Additional labels for PodMonitor | `{}` |

## Usage

### Enable Auto-Expansion on PVCs

Annotate your PVCs to enable auto-expansion:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  annotations:
    pvc-chonker.io/enabled: "true"
    pvc-chonker.io/threshold: "80%"
    pvc-chonker.io/inodes-threshold: "80%"
    pvc-chonker.io/increase: "10%"
    pvc-chonker.io/max-size: "100Gi"
    pvc-chonker.io/min-scale-up: "1Gi"
    pvc-chonker.io/cooldown: "15m"
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

### Annotation Reference

| Annotation | Description | Default | Example |
|------------|-------------|---------|----------|
| `pvc-chonker.io/enabled` | Enable auto-expansion | `false` | `"true"` |
| `pvc-chonker.io/threshold` | Storage usage threshold | `80%` | `"85%"` |
| `pvc-chonker.io/inodes-threshold` | Inode usage threshold | `80%` | `"90%"` |
| `pvc-chonker.io/increase` | Expansion amount | `10%` | `"20%"` or `"5Gi"` |
| `pvc-chonker.io/max-size` | Maximum size limit | none | `"1000Gi"` |
| `pvc-chonker.io/min-scale-up` | Minimum expansion amount | `1Gi` | `"2Gi"` or `"500Mi"` |
| `pvc-chonker.io/cooldown` | Cooldown between expansions | `15m` | `"30m"` or `"6h"` |

## Examples

### Database Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: database-storage
  annotations:
    pvc-chonker.io/enabled: "true"
    pvc-chonker.io/threshold: "85%"
    pvc-chonker.io/inodes-threshold: "90%"
    pvc-chonker.io/increase: "25%"
    pvc-chonker.io/max-size: "500Gi"
    pvc-chonker.io/min-scale-up: "2Gi"
    pvc-chonker.io/cooldown: "30m"
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 10Gi
  storageClassName: gp3
```

### Log Storage

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: log-storage
  annotations:
    pvc-chonker.io/enabled: "true"
    pvc-chonker.io/threshold: "90%"
    pvc-chonker.io/increase: "50%"
    pvc-chonker.io/max-size: "1Ti"
    pvc-chonker.io/cooldown: "1h"
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp3
```

## Monitoring

The operator exports Prometheus metrics at `:8080/metrics`. Enable the PodMonitor to scrape metrics:

```yaml
podMonitor:
  enabled: true
  additionalLabels:
    prometheus: kube-prometheus
```

## Requirements

- Kubernetes 1.19+
- CSI driver with `allowVolumeExpansion: true`
- Kubelet metrics endpoint accessible
- RBAC permissions for PVC updates

## Uninstalling

```bash
helm uninstall pvc-chonker
```

## Source Code

- <https://github.com/logicIQ/pvc-chonker>