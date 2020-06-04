#!/bin/bash -e

args=(
	-backend "${INPUT_BACKEND}"
)
docker_args=(
	--detach
	--publish 8443:8443
)

if [ -n "${INPUT_DATA}" ]; then
	INPUT_DATA=$(realpath "${INPUT_DATA}")
	args+=(-data "${INPUT_DATA}" )
	docker_args+=(--volume "${INPUT_DATA}:${INPUT_DATA}")
fi

if [ -n "${INPUT_EXTERNAL_URL}" ]; then
	args+=(-external-url "${INPUT_EXTERNAL_URL}")
fi

if [ -n "${INPUT_PUBLIC_HOST}" ]; then
	args+=(-public-host "${INPUT_PUBLIC_HOST}")
fi

exec docker run "${docker_args[@]}" "fsouza/fake-gcs-server:${INPUT_VERSION}" "${args[@]}"
