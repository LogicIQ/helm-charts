#!/bin/bash
# Generate self-signed certificates for webhook
# Usage: ./generate-webhook-certs.sh <service-name> <namespace>

SERVICE_NAME=${1:-pvc-chonker-webhook-service}
NAMESPACE=${2:-pvc-chonker-system}

# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -new -x509 -days 365 -key ca.key \
  -subj "/C=US/ST=CA/L=San Francisco/O=Test/CN=Test CA" \
  -out ca.crt

# Generate server private key
openssl genrsa -out tls.key 2048

# Generate server certificate signing request
openssl req -newkey rsa:2048 -nodes -keyout tls.key \
  -subj "/C=US/ST=CA/L=San Francisco/O=Test/CN=${SERVICE_NAME}.${NAMESPACE}.svc" \
  -out server.csr

# Generate server certificate signed by CA
openssl x509 -req \
  -extfile <(printf "subjectAltName=DNS:${SERVICE_NAME}.${NAMESPACE}.svc,DNS:${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local") \
  -days 365 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out tls.crt

# Create Kubernetes secret
kubectl create secret tls webhook-server-certs \
  --cert=tls.crt \
  --key=tls.key \
  --namespace=${NAMESPACE} \
  --dry-run=client -o yaml > webhook-secret.yaml

# Get CA bundle for webhook configuration
CA_BUNDLE=$(cat ca.crt | base64 | tr -d '\n')

echo "Generated files:"
echo "- webhook-secret.yaml (apply this to create the TLS secret)"
echo "- CA Bundle for webhook config: ${CA_BUNDLE}"

# Cleanup
rm -f ca.key ca.crt ca.srl server.csr