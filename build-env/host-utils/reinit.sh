#!/bin/bash

git clean -dfX
rm -rf feeds/
cp feeds.conf.default feeds.conf
./scripts/feeds update
./scripts/feeds install -a
make menuconfig