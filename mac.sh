#!/bin/bash
cd `dirname $0`
cd src
run.sh && \
open ./output/diff.json
