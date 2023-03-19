#!/usr/bin/env bash

if [ -z ${DOCKER_CMD+x} ]; then
    # $DOCKER_CMD is not set -> use the default
    DOCKER_CMD=docker
fi

# Make sure the docker image exists
dockerimg="fsarchiver-builder:latest"
if ! "$DOCKER_CMD" inspect ${dockerimg} >/dev/null 2>/dev/null ; then
    echo "ERROR: You must build the following docker image before you run this script: ${dockerimg}"
    exit 1
fi

# Determine the path to the git repository
fullpath="$(realpath $0)"
curdir="$(dirname ${fullpath})"
repodir="$(realpath ${curdir}/..)"
echo "curdir=${curdir}"
echo "repodir=${repodir}"

# Build fsarchiver in docker
docker run --rm --user 1000:1000 -it \
    --volume=${repodir}:/workspace \
    ${dockerimg} setarch x86_64 -- bash -c "make distclean ; ./autogen.sh && ./configure && make && make dist"
res=$?
if [ ${res} -ne 0 ]
then
    echo "ERROR: Failed to build fsarchiver"
    exit 1
fi
