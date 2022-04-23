#!/bin/bash

USER_ID=${HOST_UID:-9001}
GROUP_ID=${HOST_GID:-9001}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"
useradd -u $USER_ID -o -m user
groupmod -g $GROUP_ID user
export HOME=/home/user

cd /workspaces/RISCV
exec /usr/sbin/gosu user /bin/bash
