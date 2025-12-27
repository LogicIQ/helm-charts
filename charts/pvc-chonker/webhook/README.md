# Webhook Configuration

This directory contains webhook-related files for PVC Chonker admission webhook.

## Important: PVCGroup Requirement

**The webhook is REQUIRED for PVCGroup functionality.** PVCGroups will not work without the webhook enabled. The webhook automatically applies PVCGroup template settings to matching PVCs during creation/update.

## Certificate Options

### 1. Auto-Generated (Default)
```yaml
webhook:
  enabled: true
```
Helm automatically generates self-signed certificates during deployment.

### 2. Cert-Manager (Recommended for Production)
```yaml
webhook:
  enabled: true
  certManager: true
```
Requires cert-manager installed in cluster.

### 3. Manual Certificates
```yaml
webhook:
  enabled: true
  caBundle: "LS0tLS1CRUdJTi..."
  tlsSecretName: "my-webhook-certs"
```
Use `generate-webhook-certs.sh` to create certificates manually.

## Files

- `generate-webhook-certs.sh` - Script for manual certificate generation
- `values-webhook-manual.yaml` - Example values for manual setup