# Part 5: Ingress to Kubernetes Gateway API Migration

## 1. Core Architectural Differences (Ingress vs. Gateway API)
- **Role-Oriented Separation of Concerns:** Ingress conflates cluster/network infrastructure and application routing into a single resource (`Ingress` + controller annotations). Gateway API separates infrastructure provisioning (`GatewayClass` and `Gateway`) owned by platform/cluster operators from route definitions (`HTTPRoute`, `GRPCRoute`, etc.) owned by application teams.
- **Portability & Standardization:** Ingress relies heavily on vendor-specific annotations (`nginx.ingress.kubernetes.io/*`, `alb.ingress.kubernetes.io/*`) that break across controllers. Gateway API models common traffic features (header/query matching, traffic splitting/canary weights, redirects, URL rewrites, timeouts, CORS) as first-class, typed schema fields.
- **Cross-Namespace Routing & ReferenceGrant:** Gateway API supports explicit parent-child attachment between `HTTPRoute` and `Gateway` across namespaces using `ReferenceGrant`, enabling safe multi-tenant delegation without granting broad cluster permissions.

## 2. Migration Plan (Zero / Minimal Downtime)
1. **Audit Existing Ingress & Annotations:** Inventory all `Ingress` hosts, paths, TLS secrets, timeouts, rewrites, auth/rate-limit annotations, and backend Services.
2. **Install Gateway API CRDs & Controller:** Install standard/experimental Gateway API CRDs and deploy a Gateway controller (e.g., Envoy Gateway, Cilium, NGINX Gateway Fabric, or cloud-native Gateway controller) alongside the existing Ingress controller.
3. **Provision `GatewayClass` and `Gateway`:** Define `GatewayClass` for the chosen controller and create the `Gateway` resource with required listeners (`HTTP` / `HTTPS`), TLS certificates, and `allowedRoutes` policies.
4. **Translate `Ingress` Rules to `HTTPRoute`s:** Convert host/path rules, path types (`PathPrefix`, `Exact`), backend Service weights, and supported filters/timeouts into `HTTPRoute` manifests bound to the `Gateway` via `parentRefs`. Create any required `ReferenceGrant`s for cross-namespace backends.
5. **Validate & Cut Over Traffic:** Test routes directly against the `Gateway` address/listener (e.g., via `Host` header or DNS/LB test endpoint), shift DNS/load-balancer records or progressive traffic weights to the `Gateway`, monitor 4xx/5xx error rates and latency, and decommission legacy `Ingress` resources once verified.

## 3. Rollback & Risk Mitigation
- Keep the existing `Ingress` resources and controller active during initial `HTTPRoute` validation so traffic can be reverted quickly via DNS/LB or route cutback if unexpected behavior occurs.
- Validate rendered manifests in CI (`kubectl --dry-run=client` / controller admission validation) and test in staging with realistic traffic headers and TLS before production cutover.
