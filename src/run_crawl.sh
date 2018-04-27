#!/bin/bash
cd `dirname $0`
bundle exec ruby crawl.rb -j $1

