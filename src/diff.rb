require 'open-uri'
require 'nokogiri'
require "json"
require 'securerandom'
require "fileutils"
require 'optparse'

params = ARGV.getopts("", "src:", "dst:", "dir:")
jsons = [params["src"], params["dst"]]

if false == params["dir"].nil?
    files = Dir.glob(params["dir"] + "/*.json")
    jsons = files.sort()
    if jsons.length <= 1
        STDERR.puts "ERROR: " + params["dir"] + " must contains at least 2 json files."
        return
    end
elsif params["src"].nil? || params["dst"].nil?
    STDERR.puts "ERROR: USAGE: ruby diff.rb --src <src json> --dst <dst json>"
    return
end

all_items = []
for i in (jsons.length - 2).downto(0) do
    src_json_file_path = jsons[i]
    dst_json_file_path = jsons[-1]

    STDERR.puts src_json_file_path + " <-> " + dst_json_file_path

    src = open(src_json_file_path) do |io|
        JSON.load(io)
    end

    dst = open(dst_json_file_path) do |io|
        JSON.load(io)
    end

    dst.each do |dst_item|
        # use url as a unique key
        found = src.find {|src_item| src_item["url"] == dst_item["url"]}
        if found.nil?
            all_items << dst_item
        end
    end

    if all_items.length <= 0
        STDERR.puts "No new item found"
    else
        break
    end
end

STDERR.puts "%d items found" % all_items.length
JSON.dump(all_items, STDOUT)
