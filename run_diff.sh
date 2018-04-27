#!/bin/bash
cd `dirname $0`
./run_crawl.sh && \
./run_scrape.sh && \
./run_diff.sh && \
echo `date +%Y%m%d_%H-%M-%S:` 'Finished crawling and scraping.'
