#!/bin/bash
cd `dirname $0`
echo 'scraping: outputfile is ./json/*.json'
mkdir ./json

bundle exec ruby diff.rb --dir ./json