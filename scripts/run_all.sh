#!/bin/bash

set -e # STOP ON ERROR

# define variables for scripts
source scripts/init_vars.sh

echo "------------------------"
echo "Clean up"
echo "------------------------"

# cleanup
./scripts/cleanup.sh

echo "------------------------"
echo "initializing folders"
echo "------------------------"

# prepare folders
./scripts/init_folders.sh

echo "------------------------"
echo "downloading sources"
echo "------------------------"

# get_sources
./scripts/get_sources.sh

echo "------------------------"
echo "build linux kernel"
echo "------------------------"

# build the kernel
./scripts/build_linux_kernel.sh

echo "------------------------"
echo "build busybox"
echo "------------------------"

# build busybox
./scripts/build_busybox.sh

echo "------------------------"
echo "generate initramfs"
echo "------------------------"

# generate initramfs
./scripts/write_init.sh
./scripts/generate_initramfs.sh
