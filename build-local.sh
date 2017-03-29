#!/bin/bash


PROJECT="jamesjj/docker-nginx-pagespeed"
TAG="${GIT_COMMIT:-$(git describe --long --dirty --abbrev=10 --tags --always)}"
BUILD_DATE="$(date '+%Y%m%d')"
DOCKERFILE_PATH="."

# Delete unneeded Mac files
find . -type f -name '.DS_Store' -delete

# you must commit any local changes first!
git diff --cached --exit-code || exit 1
git diff --exit-code || exit 1


# Build with --squash if supported, or without if not
docker build \
    --squash \
    --no-cache \
    --pull \
    --label "BUILDDATE=${BUILD_DATE}" \
    --build-arg "APP_CONFIG_VERSION=${TAG}" \
    --build-arg "APP_CONFIG_BUILD_DATE=${BUILD_DATE}" \
    -t "${PROJECT}:${TAG}"  \
    "${DOCKERFILE_PATH}" \
  || \
  docker build \
    --no-cache \
    --pull \
    --label "BUILDDATE=${BUILD_DATE}" \
    --build-arg "APP_CONFIG_VERSION=${TAG}" \
    --build-arg "APP_CONFIG_BUILD_DATE=${BUILD_DATE}" \
    -t "${PROJECT}:${TAG}" \
    "${DOCKERFILE_PATH}"


echo "${PROJECT}:${TAG}"



