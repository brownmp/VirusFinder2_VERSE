#!/bin/bash

set -e


# docker build -f Dockerfile -t brownmp/virusfinder2:devel .

docker build --build-arg CACHEBUST=$(date +%s) -f Dockerfile -t brownmp/virusfinder2:devel .

# docker build --no-cache -f Dockerfile -t brownmp/virusfinder2:devel .
