#!/bin/bash
cd `dirname $0`
./run.sh && \
start ./output/diff.json
