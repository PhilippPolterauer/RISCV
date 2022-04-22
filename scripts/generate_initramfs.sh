#!/bin/bash

# change folder
cd $BUILD_FOLDER/initramfs

# setup basic filesystem
mkdir -pv $BUILD_FOLDER/initramfs/{bin,sbin,etc,proc,sys,usr/{bin,sbin}}

# copy all of busybox installation files
cp -av $BUILD_FOLDER/busybox/_install/* $BUILD_FOLDER/initramfs/

# setup basic init executable
printf "#\!/bin/sh\n# exec /bin/sh" >> $BUILD_FOLDER/initramfs/init

# make file executable
chmod +x $BUILD_FOLDER/initramfs/init 

# generate intramfs file
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $BUILD_FOLDER/initramfs.cpio.gz