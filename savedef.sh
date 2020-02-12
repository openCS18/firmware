#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR/buildroot

make savedefconfig && make linux-savedefconfig && cp output/build/linux-5.3.18/defconfig ../board/opencs18/v1/linux_defconfig && cp output/build/busybox-1.31.1/.config ../board/opencs18/v1/busybox.config