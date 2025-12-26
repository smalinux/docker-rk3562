#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-only
CONTAINER=${CONTAINER:-ghcr.io/crops/poky:ubuntu-22.04}

while getopts "c:e:uh" opt; do
	case "$opt" in
	h)
		echo "usage: $0 [-c CONTAINER] [command...]"
		echo "This script mounts the working directory into a container"
		echo "and runs the specified command inside or /bin/bash if no"
		echo "command was specified."
		echo "OPTIONS:"
		echo "  -c <container>    container image to use (default: $CONTAINER)"
		echo "  -u                pull container image updates"
		echo "  -e <VAR=value>    pass environment variable to container"
		echo "  -h                This help text"
		exit 0
		;;
	u)
		update=1
		;;
	c)
		CONTAINER="$OPTARG"
		;;
	e)
		env="$env -e $OPTARG"
		;;
	esac
done
shift $((OPTIND-1))

[ -n "$update" ] && podman pull "$CONTAINER"

volumes="-v $PWD:$PWD"
pwd_real=$(realpath $PWD)
if [ "$(realpath --no-symlinks $PWD)" != "$pwd_real" ]; then
	volumes="$volumes -v $pwd_real:$pwd_real:z"
fi

# Add common Yocto shared state and download directories if they exist
[ -d "$HOME/yocto-sstate-cache" ] && volumes="$volumes -v $HOME/yocto-sstate-cache:/sstate-cache:z"
[ -d "$HOME/yocto-downloads" ] && volumes="$volumes -v $HOME/yocto-downloads:/downloads:z"

exec podman run -it $volumes --rm \
	-e TERM -e MACHINE -e DISTRO -e BB_ENV_PASSTHROUGH_ADDITIONS \
	-e DL_DIR -e SSTATE_DIR -e TMPDIR -e BB_NUMBER_THREADS -e PARALLEL_MAKE \
	$env \
	-w "$PWD" --userns=keep-id \
	-- "$CONTAINER" "${@:-/bin/bash}"
