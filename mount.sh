#!/bin/bash
mkdir -p /tmp/dev
mount -t devtmpfs none /tmp/dev
for i in $(seq 0 9); do
  mknod -m 0660 "/tmp/dev/loop$i" b 7 "$i"
done
