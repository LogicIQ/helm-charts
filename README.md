# helm-charts

Helm charts repository for LogicIQ applications.

## Add Repository

```bash
helm repo add logiciq https://logiciq.github.io/helm-charts
helm repo update
```

## Available Charts

### konductor
Kubernetes operator for synchronization primitives (Semaphore, Barrier, Lease, Gate)

```bash
# Install konductor
helm install my-konductor logiciq/konductor

# Install with custom values
helm install my-konductor logiciq/konductor -f values.yaml
```

### pvc-chonker
Cloud-agnostic Kubernetes operator for automatic PVC expansion

```bash
# Install pvc-chonker
helm install pvc-chonker logiciq/pvc-chonker

# Install with custom threshold
helm install pvc-chonker logiciq/pvc-chonker --set controller.args.defaultThreshold=85
```

### secret-santa
Kubernetes operator for sensitive data generation with Go template support

```bash
# Install secret-santa
helm install my-secret-santa logiciq/secret-santa

# Install with dry run mode
helm install my-secret-santa logiciq/secret-santa --set controller.args.dryRun=true
```

## General Commands

### List Available Charts

```bash
helm search repo logiciq
```

### Upgrade a Release

```bash
helm upgrade <release-name> logiciq/<chart-name>
```

### Uninstall a Release

```bash
helm uninstall <release-name>
```
