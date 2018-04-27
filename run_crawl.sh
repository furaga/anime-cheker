#!/bin/bash
cd `dirname $0`
bundle exec ruby crawl.rb --video
bundle exec ruby crawl.rb --books
bundle exec ruby crawl.rb --comic
