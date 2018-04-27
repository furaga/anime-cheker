#!/bin/bash
cd `dirname $0`
echo 'scraping: outputfile is ./json/*.json'
mkdir ./scraped

#bundle exec ruby scrape.rb --download > ./scraped/`date +%Y%m%d%H%M%S`.json
bundle exec ruby scrape.rb > ./scraped/`date +%Y%m%d%H%M%S`.json
