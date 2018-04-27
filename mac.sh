#!/bin/bash
cd `dirname $0`
cd src
run.sh ../mylist.json && \
open ./output/updates.json
