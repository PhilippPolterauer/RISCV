#!/bin/bash

cd $SRC_FOLDER

# if git is available
git clone https://github.com/torvalds/linux/ -b v5.17 --single-branch --depth 1
git clone https://git.busybox.net/busybox -b 1_35_0 --single-branch --depth 1
