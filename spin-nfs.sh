!#/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

docker stop openCS18_NFS || true
docker container rm openCS18_NFS || true
sudo modprobe nfs nfsd # will prompt for root password!
docker run \
  -v $DIR/buildroot/output/target:/nfsroot \
  -d --name 'openCS18_NFS' \
  --privileged \
  -p 2049:2049 \
  -e NFS_DISABLE_VERSION_3=1 \
  -e NFS_EXPORT_0='/nfsroot *(rw,fsid=0,sync,insecure,nohide,no_root_squash,subtree_check)' \
  erichough/nfs-server

