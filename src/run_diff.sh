#!/bin/bash
cd `dirname $0`
echo 'diffing: '
mkdir ./output
bundle exec ruby diff.rb --dir ./scraped > ./output/updates.json