#!/bin/bash
set -euo pipefail

usage() {
	echo "Usage: $(basename "$0") <directory> [container-name]" >&2
	exit 1
}

[[ $# -ge 1 && $# -le 2 ]] || usage

if [[ ! -d "$1" ]]; then
	echo "error: '$1' is not a directory" >&2
	exit 1
fi
HOST_DIR="$(cd "$1" && pwd)"
DIR_NAME="$(basename "${HOST_DIR}")"

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

# container names: keep to [A-Za-z0-9_.-]
CONTAINER_NAME="${2:-${IMAGE_NAME}-${LABEL}}"
MOUNT_POINT="/home/agent/${DIR_NAME}"

container create -it \
        --name "${CONTAINER_NAME}" \
        --volume "${HOST_DIR}:${MOUNT_POINT}" \
        --workdir "${MOUNT_POINT}" \
        "${TAG_NAME}:${LABEL}" \
        /bin/bash

echo "created: ${CONTAINER_NAME} (${HOST_DIR} -> ${MOUNT_POINT})"
