#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="demo"
NAMESPACE="demo"
RELEASE_NAME="demo"
IMAGE_REPO="demo-service"
IMAGE_TAG="local"
IMAGE_FULL="${IMAGE_REPO}:${IMAGE_TAG}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== [1/4] Ensuring kind cluster '${CLUSTER_NAME}' exists ==="
if ! kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config - <<'KCEOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
KCEOF
else
  echo "Kind cluster '${CLUSTER_NAME}' already exists; reusing."
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null

echo "=== [2/4] Ensuring ingress-nginx controller is installed and ready ==="
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.hostPort.enabled=true \
  --set controller.watchIngressWithoutClass=true \
  --wait \
  --timeout=240s

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=240s

echo "=== [3/4] Building and loading '${IMAGE_FULL}' into kind cluster '${CLUSTER_NAME}' ==="
docker build -t "${IMAGE_FULL}" -f "${SCRIPT_DIR}/service/Dockerfile" "${SCRIPT_DIR}/service"
kind load docker-image "${IMAGE_FULL}" --name "${CLUSTER_NAME}"

echo "=== [4/4] Installing/upgrading Helm release '${RELEASE_NAME}' in namespace '${NAMESPACE}' ==="
helm upgrade --install "${RELEASE_NAME}" "${SCRIPT_DIR}/chart" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set image.repository="${IMAGE_REPO}" \
  --set image.tag="${IMAGE_TAG}" \
  --wait \
  --timeout=240s

kubectl rollout status "deployment/${RELEASE_NAME}" -n "${NAMESPACE}" --timeout=180s
echo "Setup completed successfully."
