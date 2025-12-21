#!/bin/bash

###
### SMA: Use Ai to write descrption, and draw graph how this script works
###
### ChatGPT: is there ready made solution for this instead of the script?

####

# [INFO]:Creating docker image
# DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
#             Install the buildx component to build images with BuildKit:
#             https://docs.docker.com/go/buildx/
####

end="\033[0m"

error="\033[0;31m"
success="\033[0;32m"
warn="\033[0;33m"
info="\033[0;36m"
debug="\033[38;5;216m"

function debug() {
    echo -e "$debug[DEBUG]:$@$end"
}
function info() {
    echo -e "$info[INFO]:$@$end"
}
function warn() {
    echo -e "$warn[WARN]:$@$end"
}
function error() {
    echo -e "$error[ERROR]:$@$end"
}
function success() {
    echo -e "$success[SUCCESS]:$@$end"
}


DOCKERIMAGE="yoctoimage"
IMAGEVERSION="kirkstone"
HOSTVOLUME="$PWD/Volume"
URL_POKY="git://git.yoctoproject.org/poky"
URL_RPI="git://git.yoctoproject.org/meta-raspberrypi"
REPO_POKY="$HOSTVOLUME/poky"
REPO_RPI="$REPO_POKY/meta-raspberrypi"
DOCKERVOLUME="/home/$(whoami)/Volume"
DOCKERCONTAINER="yocto-container"



function get_ids() {
    USERNAME="$(whoami)"
    PUID="$(id -u "$USERNAME")"
    PGID="$(id -g "$USERNAME")"
    debug "Username: $USERNAME"
    debug "User ID: $PUID"
    debug "Group ID: $PGID"
}

function is_docker_img_present() {
    if docker images "$DOCKERIMAGE:$IMAGEVERSION" | grep -q $DOCKERIMAGE; then
        return 0
    fi
    return 1
}

function delete_docker_image() {
    info "Deleting $DOCKERIMAGE:$IMAGEVERSION..."
    if ! docker rmi $DOCKERIMAGE:$IMAGEVERSION; then
        error "Failed to delete Image. Exiting..."
        exit 1
    fi
}

function create_docker_image() {
    info "Creating docker image"
    if ! docker build -t "$DOCKERIMAGE:$IMAGEVERSION" \
        --build-arg USERNAME="$USERNAME" \
        --build-arg PUID="$PUID" \
        --build-arg PGID="$PGID" ./; then
        error "Failed to build docker image"
        exit 1
    fi
    success "docker image built successfullly"
}


function build_docker_image() {

    if is_docker_img_present; then
        warn -b "$DOCKERIMAGE:$IMAGEVERSION Docker image already present"
        warn "Do you want to overwrite? Otherwise present image will be used. [y/N]"
        read -r key
        if [[ $key != "y" && $key != "Y" ]]; then
            info "Skipping creating image"
            return 0
        else
            delete_docker_image
        fi
    fi
    create_docker_image
}

function create_volume_folder() {

    if [ ! -d "$HOSTVOLUME" ]; then
        if ! mkdir -p "$HOSTVOLUME"; then
            error "Failed to create folder $HOSTVOLUME"
            exit 1
        fi
        success "Folder '$HOSTVOLUME' created successfully"
    else
        info "Folder '$HOSTVOLUME already exists"
    fi
}

function is_repo_cloned() {
    debug "$1"
    if [ -d "$1/.git" ]; then
        debug "repo present"
        return 0
    else
        debug "repo not present"
        return 1
    fi
}


function clone_repo() {
    if ! git clone -b kirkstone $1; then
        error "Failed to clone $1"
        exit 1
    fi
}


function clone_target() {
    if ! is_repo_cloned "$REPO_POKY"; then
        cd $HOSTVOLUME
        clone_repo "$URL_POKY"
        cd $REPO_POKY
        clone_repo "$URL_RPI"
    else
        if ! is_repo_cloned "$REPO_RPI"; then
            cd $REPO_POKY
            clone_repo "$URL_RPI"
        fi
    fi

}


function run_docker_container() {
    info "Creating docker container from $DOCKERIMAGE:$IMAGEVERSION"

    # Mount current directory instead of Volume subdirectory
    if ! docker run -i -t --rm --name "$DOCKERCONTAINER" \
        -v "$PWD":"$DOCKERVOLUME" \
        -w "$DOCKERVOLUME" \
        "$DOCKERIMAGE:$IMAGEVERSION" ./entrypoint.sh ; then
        error "Failed to run docker container"
        exit 1
    fi
}

function copy_entrypoint(){
    cp entrypoint.sh Volume
}

get_ids
build_docker_image
create_volume_folder
#copy_entrypoint
#clone_target
run_docker_container

