#!/bin/bash

GHCR_IMAGE="ghcr.io/astdyn/stationeers-server:latest"

docker tag didstopia/stationeers-server:latest "$GHCR_IMAGE"
docker push "$GHCR_IMAGE"
