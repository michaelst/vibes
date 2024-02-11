#!/bin/sh

set -e

cd "`dirname $0`"/..

COMMIT_SHA=$(git rev-parse HEAD)

helm upgrade --install vibes oci://ghcr.io/michaelst/helm/cloud-57 \
  -f .devops/values.yaml \
  --set image.repository=ghcr.io/michaelst/vibes \
  --set image.tag=$COMMIT_SHA \
  --version 1.0.5 \
  --atomic \
  -n vibes
