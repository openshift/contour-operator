#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:-docker.io/projectcontour/contour-operator:main}

rm -f config/default/operator_image.yaml
cat << EOF >> config/default/operator_image.yaml
# This patch updates the operator image to use images built for PRs and other testing images.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: contour-operator
  namespace: system
spec:
  template:
    spec:
      containers:
      - name: contour-operator
        image: ${IMAGE}
EOF

