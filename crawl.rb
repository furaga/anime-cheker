require 'open-uri'
require 'nokogiri'
require 'net/http'
require 'json'
require 'uri'
require 'optparse'
#require 'robotex'

# robotex = Robotex.new
# puts robotex.allowed?("http://www.yahoo.co.jp/")

$charset = nil
$user_agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.63 Safari/537.36'

def read_html(url)
    content = open(url, "User-Agent" => $user_agent) do |f|
        $charset = f.charset
        f.read
    end
    # DOS攻撃しないようにHTML読み込み後は常に一秒待つ
    sleep(0.2)
    content
end

def save_html(content, filepath)
    dirname = File.dirname(filepath)
    FileUtils.mkdir_p(dirname) unless FileTest.exist?(dirname)
    File.open(filepath, "w") do |f|
        f.puts(content)
        puts "saved: " + filepath
    end
end

def download(url, savepath)
    begin
        event_html = read_html(url)
        encoded = URI.encode(url)
        save_html(event_html, savepath)
    rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
            puts '404 Not Found: ' + url
        else
            puts 'Some error happened during reading ' + url
        end
        puts 'Failed to download "' + url + '"'
    end
end


params = ARGV.getopts("j:", "json:")

json_file_path = params["json"]
if json_file_path.nil?
    json_file_path = params["j"]
end
if json_file_path.nil?
   STDERR.puts "USAGE: ruby crawl.rb --json <json path> "
   return
end

puts "read " + json_file_path

json_data = open(json_file_path) do |io|
    JSON.load(io)
end


json_data.each do |d|
    uri = URI.parse(d["url"])
    save_path = uri.path.gsub(/^\//, '')
    save_path = save_path.gsub("/", '-')
    save_path = "./data/html/" + save_path + ".html"
    download(d["url"], save_path)
end
