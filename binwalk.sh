#!/bin/sh

docker run -it --rm \
  -v "$(pwd):/iot" \
  -w /iot \
  cow0o0/binwalk:2.3.3 \
  "$@"
