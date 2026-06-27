#!/usr/bin/env bash

ROOT="${HOME}/work/foundry"

source "${ROOT}/lib/common.sh"

section "Host"

hostname

platform

section "Core"

check git
check gh
check docker
check python3
check node
check npm
check gcc
check cmake
check make
check qemu-system-x86_64
check docker

summary
