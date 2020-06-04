#!/bin/bash -e

args=(
	-backend "${INPUT_BACKEND}"
)

docker_args=(
	--detach
	--publish 4443:4443
)

docker_image=fsouza/fake-gcs-server:${INPUT_VERSION}

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

docker pull "${docker_image}"
container_id=$(docker run "${docker_args[@]}" "${docker_image}" "${args[@]}")

docker ps --latest

timeout=10
echo "waiting up to ${timeout}s for server to come up"
if ! timeout 10 bash -c 'while ! wget -qO /dev/null -T 1 --no-check-certificate https://0.0.0.0:4443/storage/v1/b; do echo server not available; sleep 1; done'; then
	echo "Failed to connect to the server after ${timeout}s" >&2
	echo "Logs from docker: " >&2
	docker logs "${container_id}"
	exit 1
fi
