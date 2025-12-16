# secret-santa

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Kubernetes operator for sensitive data generation with Go template support

**Homepage:** <https://github.com/logicIQ/secret-santa>

## Source Code

* <https://github.com/logicIQ/secret-santa>

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm repo add logiciq https://logiciq.github.io/helm-charts
helm repo update
helm install my-release logiciq/secret-santa
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the secret-santa chart and their default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.affinity | object | `{}` | Affinity for controller deployment. |
| controller.annotations | object | `{}` | Annotations to be added to controller deployment. |
| controller.args.additionalArgs | list | `[]` | Specify additional args. |
| controller.args.dryRun | bool | `false` | Enable dry run mode (validate templates without creating secrets). |
| controller.args.excludeAnnotations | list | `[]` | Excluded annotations for processing. |
| controller.args.excludeLabels | list | `[]` | Excluded labels for processing. |
| controller.args.healthProbeBindAddress | string | `":8081"` | Health probe endpoint address. |
| controller.args.includeAnnotations | list | `[]` | Required annotations for processing. |
| controller.args.includeLabels | list | `[]` | Required labels for processing. |
| controller.args.leaderElect | bool | `false` | Enable leader election. |
| controller.args.logFormat | string | `"json"` | Log format: json or console. |
| controller.args.logLevel | string | `"info"` | Log level: debug, info, warn, error. |
| controller.args.maxConcurrentReconciles | int | `1` | Maximum concurrent reconciles. |
| controller.args.metricsBindAddress | string | `":8080"` | Metrics endpoint address. |
| controller.args.watchNamespaces | list | `[]` | Namespaces to watch (empty = all). |
| controller.nodeSelector | object | `{}` | Map of key-value pairs for scheduling pods on specific nodes. |
| controller.podAnnotations | object | `{}` | Annotations to be added to controller pods. |
| controller.podLabels | object | `{}` | Pod labels to be added to controller pods. |
| controller.podSecurityContext | object | `{"fsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | Security Context to be applied to the controller pods. |
| controller.priorityClassName | string | `""` | Priority class name to be applied to the controller pods. |
| controller.replicas | int | `1` | Specify the number of replicas of the controller Pod. |
| controller.resources | object | `{"limits":{"cpu":"500m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"64Mi"}}` | Specify resources. |
| controller.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Security Context to be applied to the controller container within controller pods. |
| controller.terminationGracePeriodSeconds | int | `10` | Specify terminationGracePeriodSeconds. |
| controller.tolerations | list | `[]` | Ensure pods are not scheduled on inappropriate nodes. |
| crd.install | bool | `true` | Install the SecretSanta CRD. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `nil` | secret-santa image pullPolicy. |
| image.pullSecrets | list | `[]` | Image pull secrets for private registries. |
| image.repository | string | `"logiciq/secret-santa"` | secret-santa image repository to use. |
| image.tag | string | `nil` | secret-santa image tag to use. |
| nameOverride | string | `""` |  |
| podMonitor.additionalLabels | object | `{}` | Additional labels that can be used so PodMonitor will be discovered by Prometheus. |
| podMonitor.enabled | bool | `false` | If true, creates a Prometheus Operator PodMonitor. |
| podMonitor.interval | string | `""` | Interval that Prometheus scrapes metrics. |
| podMonitor.metricRelabelings | list | `[]` | MetricRelabelConfigs to apply to samples before ingestion. |
| podMonitor.namespace | string | `""` | Namespace which Prometheus is running in. |
| podMonitor.relabelings | list | `[]` | RelabelConfigs to apply to samples before scraping. |
| podMonitor.scheme | string | `"http"` | Scheme to use for scraping. |
| podMonitor.scrapeTimeout | string | `""` | The timeout after which the scrape is ended |
| serviceAccount.annotations | object | `{}` | Annotations to be added to the service account. |
| serviceAccount.automountServiceAccountToken | bool | `true` | Controls the automatic mounting of ServiceAccount API credentials. |
| serviceAccount.enabled | bool | `true` | Creates a ServiceAccount for the controller deployment. |

## Examples

### Basic Secret Generation

```yaml
apiVersion: secrets.secret-santa.io/v1alpha1
kind: SecretSanta
metadata:
  name: basic-secret
spec:
  secretName: my-app-secret
  generators:
  - name: password
    type: random_password
    config:
      length: 16
  - name: api_key
    type: random_string
    config:
      length: 32
  template: |
    password: {{ .password }}
    api-key: {{ .api_key }}
```

### TLS Certificate Generation

```yaml
apiVersion: secrets.secret-santa.io/v1alpha1
kind: SecretSanta
metadata:
  name: tls-secret
spec:
  secretName: my-tls-secret
  secretType: kubernetes.io/tls
  generators:
  - name: ca_key
    type: tls_private_key
    config:
      algorithm: RSA
      rsa_bits: 2048
  - name: ca_cert
    type: tls_self_signed_cert
    config:
      key_algorithm: RSA
      private_key_pem: "{{ .ca_key }}"
      subject:
        common_name: "My CA"
      validity_period_hours: 8760
      is_ca_certificate: true
  - name: server_key
    type: tls_private_key
    config:
      algorithm: RSA
      rsa_bits: 2048
  - name: server_cert
    type: tls_locally_signed_cert
    config:
      cert_request_pem: "{{ .server_csr }}"
      ca_key_algorithm: RSA
      ca_private_key_pem: "{{ .ca_key }}"
      ca_cert_pem: "{{ .ca_cert }}"
      validity_period_hours: 8760
  - name: server_csr
    type: tls_cert_request
    config:
      key_algorithm: RSA
      private_key_pem: "{{ .server_key }}"
      subject:
        common_name: "my-service.default.svc.cluster.local"
      dns_names:
        - "my-service"
        - "my-service.default"
        - "my-service.default.svc"
        - "my-service.default.svc.cluster.local"
  template: |
    tls.crt: {{ .server_cert | b64enc }}
    tls.key: {{ .server_key | b64enc }}
```

## Supported Generators

### TLS
- `tls_private_key` - Generate private keys
- `tls_self_signed_cert` - Self-signed certificates
- `tls_cert_request` - Certificate signing requests
- `tls_locally_signed_cert` - Locally signed certificates

### Cryptographic
- `crypto_hmac` - HMAC generation
- `crypto_aes_key` - AES encryption keys
- `crypto_rsa_key` - RSA key pairs
- `crypto_ed25519_key` - Ed25519 keys
- `crypto_chacha20_key` - ChaCha20 keys
- `crypto_xchacha20_key` - XChaCha20 keys
- `crypto_ecdsa_key` - ECDSA keys
- `crypto_ecdh_key` - ECDH keys

### Random Data
- `random_password` - Secure passwords
- `random_string` - Random strings
- `random_uuid` - UUIDs
- `random_integer` - Random integers
- `random_bytes` - Random byte arrays
- `random_id` - Random identifiers

### Time-based
- `time_static` - Static timestamps