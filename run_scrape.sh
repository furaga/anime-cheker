#!/bin/bash
cd `dirname $0`
echo 'scraping: outputfile is ./json/*.json'
mkdir ./json
bundle exec ruby scrape.rb --video > ./json/items.json
bundle exec ruby scrape.rb --comic > ./json/items-comic.json
