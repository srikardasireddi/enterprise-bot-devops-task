# Part 4: Kubernetes & Helm Debugging Lab Findings

## Environment & Post-Sleep Recovery
- Cluster: `kind` (`demo` / `demo-control-plane`) with `cluster-state/namespace.yaml` (`debug-lab`) and `cluster-state/limits.yaml` (`debug-lab-guardrails` `LimitRange`).
- After laptop sleep/wake, in-cluster DNS (`coredns` in `kube-system`) experienced transient lookup/connection errors (`dial tcp: lookup kubernetes.default.svc on 10.96.0.10:53: read: connection refused`), resolved by restarting `coredns` and rolling out `debug-lab` deployments.

## Defects Identified & Remediated in `broken-chart/`
1. **`migrate` Job `restartPolicy`:** Updated `restartPolicy` to `Never` (Jobs cannot use `Always`).
2. **Non-Root Security Context & Port Configuration:** Set explicit `runAsUser: 65532` alongside `runAsNonRoot: true` where required by `PodSecurity` / non-root enforcement, and wired `PORT` consistently to `.Values.common.port` (`8080`).
3. **`gateway` `BACKEND_URL`:** Pointed `BACKEND_URL` to `http://backend.debug-lab.svc:8080` so `gateway` reaches `backend` in `debug-lab` and reports `backend=ok` on `/status`.
4. **RBAC `RoleBinding` Subject:** Bound `Role` `reporter-read` (`pods` `get`, `list`) to `ServiceAccount` `reporter` in `.Release.Namespace` (`debug-lab`).
5. **`metrics` Resource Limits:** Adjusted `metrics` CPU request/limit (`100m` request / `500m` limit) within `debug-lab-guardrails` `LimitRange` bounds (`max` CPU `"1"`, memory `512Mi`).
6. **`worker` Cache Volume:** Added an `emptyDir` volume mounted at `/var/cache/app` so `worker` can write cache data under `readOnlyRootFilesystem: true`.
