#!/bin/bash
cd `dirname $0`
cd src
./run.sh && \
start ./output/diff.json
