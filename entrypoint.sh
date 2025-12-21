#!/bin/bash

# Base directory is the current working directory (mounted from host)
BASE_DIR="$PWD"
BUILD_DIR="$BASE_DIR/build"
OE_CORE="$BASE_DIR/layers/openembedded-core"

# Color codes
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

function debug_env() {
    debug "BASE_DIR: $BASE_DIR"
    debug "BUILD_DIR: $BUILD_DIR"
    debug "OE_CORE: $OE_CORE"
}

function check_environment() {
    info "Checking environment..."

    if [ ! -d "$BUILD_DIR" ]; then
        error "Build directory not found: $BUILD_DIR"
        exit 1
    fi

    if [ ! -f "$BUILD_DIR/conf/local.conf" ]; then
        error "local.conf not found: $BUILD_DIR/conf/local.conf"
        exit 1
    fi

    if [ ! -f "$BUILD_DIR/conf/bblayers.conf" ]; then
        error "bblayers.conf not found: $BUILD_DIR/conf/bblayers.conf"
        exit 1
    fi

    if [ ! -d "$OE_CORE" ]; then
        error "OpenEmbedded Core not found: $OE_CORE"
        exit 1
    fi

    success "All required directories and files exist"
}

function setup_build_env() {
    info "Setting up build environment..."

    cd "$OE_CORE" || exit 1

    # Source the build environment with existing build directory
    source oe-init-build-env "$BUILD_DIR"

    success "Build environment initialized"
    info "Current directory: $PWD"
}

function show_yocto_vars() {
    info "Checking Yocto configuration variables..."
    bitbake -e | grep "^DL_DIR="
    bitbake -e | grep "^SSTATE_DIR="
    bitbake -e | grep "^TMPDIR="
    bitbake -e | grep "^TOPDIR="
}

function build_image() {
    info "Starting image build: core-image-minimal"
    bitbake core-image-minimal
}

# Main execution
debug_env
check_environment
setup_build_env
show_yocto_vars
build_image

# Drop into interactive shell
exec /bin/bash
