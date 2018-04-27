#!/bin/bash
cd `dirname $0`
echo 'scraping: outputfile is ./json/*.json'
mkdir ./json

bundle exec ruby scrape.rb --download > ./json/`date +%Y%m%d%H%M%S`.json