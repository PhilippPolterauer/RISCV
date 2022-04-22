#!/bin/bash
cd $SRC_FOLDER/linux
# configure make all default
make O=$BUILD_FOLDER/linux/ defconfig
# build linux 
make O=$BUILD_FOLDER/linux/ -j8