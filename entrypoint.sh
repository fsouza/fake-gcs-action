#!/bin/bash -e

args=(
	-backend "${INPUT_BACKEND}"
	-cert-location "$(printenv INPUT_CERT-LOCATION)"
	-private-key-location "$(printenv INPUT_PRIVATE-KEY-LOCATION)"
	-port "${INPUT_PORT}"
	-scheme "${INPUT_SCHEME}"
)

docker_args=(
	--detach
	--publish 4443:4443
)

INPUT_EXTERNAL_URL=$(printenv INPUT_EXTERNAL-URL)
INPUT_PUBLIC_HOST=$(printenv INPUT_PUBLIC-HOST)

docker_image=fsouza/fake-gcs-server:${INPUT_VERSION}

if [ -n "${INPUT_DATA}" ]; then
	if [ -n "${INPUT_DEBUG}" ]; then
		echo "INPUT_DATA=${INPUT_DATA}"
		echo "RUNNER_WORKSPACE=${RUNNER_WORKSPACE}"
		echo "GITHUB_WORKSPACE=${GITHUB_WORKSPACE}"
		echo "HOME=${HOME}"
	fi

	# RUNNER_WORKSPACE won't be populated at this point, so check the directory
	# relative to GITHUB_WORKSPACE.
	if ! [ -d "${GITHUB_WORKSPACE}/${INPUT_DATA}" ]; then
		echo "ERROR: input data should be a directory. Make sure it exists and is specified as a relative path" >&2
		exit 2
	fi

	# Github doesn't give us the repository name directly, so figure it out on
	# our own.
	REPOSITORY_NAME="${GITHUB_REPOSITORY#"${GITHUB_REPOSITORY_OWNER}"/}"

	# Build a data path relative to RUNNER_WORKSPACE, including the repository
	# name that wasn't included in GITHUB_WORKSPACE.
	DATA_PATH="${RUNNER_WORKSPACE}/${REPOSITORY_NAME}/${INPUT_DATA}"

	args+=(-data "${DATA_PATH}")
	docker_args+=(--volume "${DATA_PATH}:${DATA_PATH}")
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
if ! timeout 10 bash -c 'while ! docker exec '"${container_id}"' wget -qO /dev/null -T 1 --no-check-certificate '"${INPUT_SCHEME}"'://0.0.0.0:'"${INPUT_PORT}"'/storage/v1/b; do echo "server not available yet, sleeping..."; sleep 1; done'; then
	echo "Failed to connect to the server after ${timeout}s" >&2
	echo "Logs from docker: " >&2
	docker logs "${container_id}"
	exit 1
fi

echo "Server started successfully!"
if [ -n "${INPUT_DEBUG}" ]; then
	echo "Logs from container: "
	docker logs "${container_id}"
fi
