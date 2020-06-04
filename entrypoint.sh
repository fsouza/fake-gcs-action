#!/bin/bash -e

args=(
	-backend "${INPUT_BACKEND}"
)

if [ -n "${INPUT_DATA}" ]; then
	INPUT_DATA=$(realpath "${INPUT_DATA}")
	args+=(-data "${INPUT_DATA}" -v "${INPUT_DATA}:${INPUT_DATA}")
fi

if [ -n "${INPUT_EXTERNAL_URL}" ]; then
	args+=(-external-url "${INPUT_EXTERNAL_URL}")
fi

if [ -n "${INPUT_PUBLIC_HOST}" ]; then
	args+=(-public-host "${INPUT_PUBLIC_HOST}")
fi

exec docker run -d --publish 4443:4443 "fsouza/fake-gcs-version:${INPUT_VERSION}" "${args[@]}"
