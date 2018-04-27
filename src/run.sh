#!/bin/bash
cd `dirname $0`
./run_crawl.sh $1 && \
echo '---------' && \
./run_scrape.sh && \
echo '---------' && \
./run_diff.sh && \
echo '---------' && \
echo `date +%Y%m%d_%H-%M-%S:` 'Finished crawling and scraping.'
