require 'open-uri'
require 'nokogiri'
require "json"
require 'securerandom'
require "fileutils"
require 'optparse'

params = ARGV.getopts("d", "download")
$do_download_image = params["d"]


def download(url, savepath)
  dirname = File.dirname(savepath)
  FileUtils.mkdir_p(dirname) unless FileTest.exist?(dirname)
  open(savepath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
      STDERR.puts "saved: " + savepath
    end
  end
end

def download_thumbnail(url)
    publicImageURL = "/img/" + SecureRandom.hex(8) + ".png"
    download(url,  "./data" + publicImageURL)
    return publicImageURL
end

def scrape_niconico_anime(path)
    items = []

    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    divs = doc.css('.g-video.from_video')
    divs.each do |div|
        item = {}

        links = div.css('.thumb_anchor.g-video-link')
        if links.length <= 0 then
            STDERR.puts ".thumb_anchor.g-video-link not found: " + url + "(" + title + ")"
        end

        lnk = links[0]
        url = lnk.attribute('href').value.strip
        title = lnk.attribute('title').value.strip
        item["url"] = url
        item["title"] = title
        item["root"] = path

        imgs = lnk.css('.g-thumbnail-image')
        if imgs.length <= 0 then
            STDERR.puts "img not found: " + url + "(" + title + ")"
        end

        img = imgs[0]
        url_attr = img.attribute("src")
        if url_attr.nil? then
            url_attr = img.attribute("data-original")
        end
        thumbnail_url = url_attr.value.strip
        save_filepath = ""
        if $do_download_image then
            save_filepath = download_thumbnail(thumbnail_url)
        end
        item["thumbnail_rawurl"] = thumbnail_url
        item["thumbnail_url"] = save_filepath

        items << item
    end

    return items
end

def scrape_narou(path)
    items = []

    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    sublist = doc.css('.novel_sublist2')
    sublist.each do |subtitle|
        item = {}
        item["root"] = path
        subtitle.css('a').each do |a|
            item['url'] = "http://ncode.syosetu.com" + a.attribute("href").value.strip
            item['title'] = a.inner_html.strip
        end
        subtitle.css('.long_update').each do |dt|
            item['timestamp'] = dt.inner_html.strip
        end
        items << item
    end

    if items.length >= 10 then
        return items.slice(-10..-1)
    end
    return items
end

files = Dir.glob('./data/html/*.html')
all_items = []
files.each do |f|
    if f.include?("ch.nicovideo.jp") then
        # ニコニコアニメチャンネルページ
        STDERR.puts "scrape (niconico): " + f
        items = scrape_niconico_anime(f)
        all_items.concat(items)
    end
    if f.include?("ncode.syosetu.com") then
        # 小説家になろう小説一覧ページ
        STDERR.puts "scrape (narou): " + f
        items = scrape_narou(f)
        all_items.concat(items)
    end
end

JSON.dump(all_items, STDOUT)
