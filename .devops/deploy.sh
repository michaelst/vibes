#!/bin/sh

set -e

cd "`dirname $0`"/..

COMMIT_SHA=$(git rev-parse HEAD)

docker buildx use multi-platform
docker buildx build --platform=linux/amd64,linux/arm64 -t ghcr.io/michaelst/vibes:$COMMIT_SHA . --push --provenance=false

helm upgrade --install vibes oci://ghcr.io/michaelst/helm/cloud-57 \
  -f .devops/values.yaml \
  --set image.repository=ghcr.io/michaelst/vibes \
  --set image.tag=$COMMIT_SHA \
  --version 1.0.6 \
  --atomic \
  -n vibes
