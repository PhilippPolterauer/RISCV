#!/bin/bash
mkdir -p $BUILD_FOLDER/busybox
cd $SRC_FOLDER/busybox
make O=$BUILD_FOLDER/busybox/ defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g' $BUILD_FOLDER/busybox/.config
make O=$BUILD_FOLDER/busybox/ -j8
make O=$BUILD_FOLDER/busybox/ install