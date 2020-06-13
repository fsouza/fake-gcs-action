#!/bin/bash -e

cd /github/workspace

args=(
	-backend "${INPUT_BACKEND}"
)

docker_args=(
	--detach
	--publish 4443:4443
)

INPUT_EXTERNAL_URL=$(printenv INPUT_EXTERNAL-URL)
INPUT_PUBLIC_HOST=$(printenv INPUT_PUBLIC-HOST)

docker_image=fsouza/fake-gcs-server:${INPUT_VERSION}

if [ -n "${INPUT_DATA}" ]; then
	if ! [ -d "${INPUT_DATA}" ]; then
		echo "ERROR: input data should be a directory. Make sure it exists and is specified as a relative path" >&2
		exit 2
	fi

	INPUT_DATA=$(realpath --relative-to "${INPUT_DATA}")
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

timeout=10
echo "waiting up to ${timeout}s for server to come up"
if ! timeout 10 bash -c 'while ! docker exec '"${container_id}"' wget -qO /dev/null -T 1 --no-check-certificate https://0.0.0.0:4443/storage/v1/b; do echo "server not available yet, sleeping..."; sleep 1; done'; then
	echo "Failed to connect to the server after ${timeout}s" >&2
	echo "Logs from docker: " >&2
	docker logs "${container_id}"
	exit 1
fi
