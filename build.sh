#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="$(basename "${SCRIPT_DIR}")"
BRANCH_NAME="$(git -C "${SCRIPT_DIR}" rev-parse --abbrev-ref HEAD)"
if [[ "${BRANCH_NAME}" == "HEAD" ]]; then
	# detached HEAD: fall back to the short commit id
	BRANCH_NAME="$(git -C "${SCRIPT_DIR}" rev-parse --short=7 HEAD)"
fi
# image tags allow only [A-Za-z0-9_.-]; replace anything else (e.g. "/") with "-"
LABEL="$(printf '%s' "${BRANCH_NAME}" | tr -c 'A-Za-z0-9_.-' '-')"
TAG_NAME="ghcr.io/ahrimak/${IMAGE_NAME}"

container build -t "${TAG_NAME}:${LABEL}" \
	--build-arg USERNAME=agent \
	--build-arg UID=1000 \
	--build-arg GID=1000 "$SCRIPT_DIR"
