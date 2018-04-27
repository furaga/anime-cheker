#!/bin/bash
cd `dirname $0`
./run.sh && \
open ./output/diff.json
