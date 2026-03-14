# Kubernetes Deployment Manifests Generator

Generate production-ready Kubernetes deployment manifests for an application.

## Arguments

$ARGUMENTS - `<app-name>` - The name of the application (used for resource naming and labels)

## Instructions

1. **Parse the app name** from `$ARGUMENTS`. If not provided, infer from the project directory name or `package.json`/manifest name.

2. **Detect the application** by scanning the project:
   - Container port (from Dockerfile `EXPOSE`, or ask)
   - Health check endpoints (from existing health routes, or default to `/health`)
   - Environment variables needed (from `.env.example` or `.env`)
   - Resource requirements (estimate from stack: Node ~256Mi, Go ~128Mi, Java ~512Mi)

3. **Create the `k8s/` directory** in the project root.

4. **Generate the following manifest files**:

### `k8s/namespace.yml`
- Create a dedicated namespace for the application
- Add labels: `app.kubernetes.io/name`, `app.kubernetes.io/managed-by`

### `k8s/deployment.yml`
```yaml
apiVersion: apps/v1
kind: Deployment
```
- Replicas: 3 (configurable)
- Labels following Kubernetes recommended labels:
  - `app.kubernetes.io/name: <app-name>`
  - `app.kubernetes.io/version: <version>`
  - `app.kubernetes.io/component: server`
  - `app.kubernetes.io/part-of: <app-name>`
  - `app.kubernetes.io/managed-by: kubectl`
- **Rolling update strategy**:
  - `maxSurge: 1`
  - `maxUnavailable: 0` (zero-downtime)
- **Container spec**:
  - Image: `<registry>/<app-name>:<tag>` (with placeholder)
  - `imagePullPolicy: IfNotPresent`
  - Container port matching the app
  - `envFrom` referencing ConfigMap and Secret
  - **Liveness probe**: HTTP GET to health endpoint, `initialDelaySeconds: 15`, `periodSeconds: 20`, `failureThreshold: 3`
  - **Readiness probe**: HTTP GET to readiness endpoint, `initialDelaySeconds: 5`, `periodSeconds: 10`, `failureThreshold: 3`
  - **Startup probe**: HTTP GET to health endpoint, `initialDelaySeconds: 10`, `periodSeconds: 5`, `failureThreshold: 30` (allows 150s startup)
  - **Resource limits and requests**:
    - Requests: CPU `100m`, Memory `128Mi` (adjust per stack)
    - Limits: CPU `500m`, Memory `512Mi` (adjust per stack)
  - Security context:
    - `runAsNonRoot: true`
    - `runAsUser: 1001`
    - `readOnlyRootFilesystem: true`
    - `allowPrivilegeEscalation: false`
    - `capabilities: { drop: ["ALL"] }`
- Pod anti-affinity to spread across nodes
- `terminationGracePeriodSeconds: 30`

### `k8s/service.yml`
```yaml
apiVersion: v1
kind: Service
```
- Type: `ClusterIP`
- Port: 80 -> container port
- Selector matching deployment labels

### `k8s/ingress.yml`
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
```
- TLS configuration with placeholder domain and secret name
- Annotations for:
  - `nginx.ingress.kubernetes.io/ssl-redirect: "true"`
  - `cert-manager.io/cluster-issuer: "letsencrypt-prod"` (if cert-manager is used)
  - Rate limiting annotations
- Path-based routing to the service

### `k8s/configmap.yml`
```yaml
apiVersion: v1
kind: ConfigMap
```
- Non-sensitive configuration values
- Application-specific settings extracted from `.env.example`

### `k8s/secret.yml`
```yaml
apiVersion: v1
kind: Secret
type: Opaque
```
- Placeholder values (base64 encoded)
- Comment noting to use external secret management in production (Sealed Secrets, External Secrets Operator, Vault)
- Include all sensitive env vars from `.env.example`

### `k8s/hpa.yml`
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
```
- Min replicas: 2
- Max replicas: 10
- Target CPU utilization: 70%
- Target memory utilization: 80%
- Scale-down stabilization: 300s
- Scale-up behavior: max 2 pods per 60s

### `k8s/network-policy.yml`
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
```
- Default deny all ingress
- Allow ingress only from:
  - Ingress controller namespace
  - Same namespace (for inter-service communication)
- Allow egress to:
  - DNS (port 53)
  - Database services
  - External HTTPS (port 443)

### `k8s/pdb.yml`
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
```
- `minAvailable: 1` (or `maxUnavailable: 1` depending on replica count)

### `k8s/service-account.yml`
- Dedicated ServiceAccount for the application
- `automountServiceAccountToken: false` (unless needed)

5. **Generate a `k8s/kustomization.yml`** that references all the above resources, making it easy to deploy with `kubectl apply -k k8s/`.

6. **Write all files** to the `k8s/` directory.

7. **Print a summary** with:
   - Files generated and their purposes
   - How to deploy:
     - `kubectl apply -k k8s/`
     - Or individual: `kubectl apply -f k8s/`
   - How to verify: `kubectl get all -n <namespace>`
   - Things to customize before deploying:
     - Container image registry and tag
     - Domain name in Ingress
     - Resource limits based on actual usage
     - Secret values (use proper secret management)
   - Recommended next steps:
     - Set up cert-manager for automatic TLS
     - Configure external secret management
     - Set up monitoring with Prometheus ServiceMonitor
