require 'open-uri'
require 'nokogiri'
require "json"
require 'securerandom'
require "fileutils"
require 'optparse'

params = ARGV.getopts("", "src:", "dst:", "dir:")

src_json_file_path = params["src"]
dst_json_file_path = params["dst"]

if false == params["dir"].nil?
    files = Dir.glob(params["dir"] + "/*.json")
    sorted = files.sort()
    src_json_file_path = sorted[-2]
    dst_json_file_path = sorted[-1]
end

if src_json_file_path.nil? || dst_json_file_path.nil?
    STDERR.puts "USAGE: ruby diff.rb --src <src json> --dst <dst json>"
    return
end

STDERR.puts "src " + src_json_file_path
STDERR.puts "dst " + dst_json_file_path
STDERR.puts "search items which appear only in " + dst_json_file_path

src = open(src_json_file_path) do |io|
    JSON.load(io)
end

dst = open(dst_json_file_path) do |io|
    JSON.load(io)
end

all_items = []
dst.each do |dst_item|
    # use url as a unique key
    found = src.find {|src_item| src_item["url"] == dst_item["url"]}
    if found.nil?
        all_items << dst_item
    end
end

STDERR.puts "%d items found" % all_items.length
JSON.dump(all_items, STDOUT)
