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

    divs = doc.css('.g-video.g-item-odd.from_video')
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

def scrape_narou(path, datas)
    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    tables = doc.css('.favnovel')
    tables.each do |tbl|
        data = {}
        tbl.css('.title2 a').each do |a|
            data['title'] = a.inner_html.strip
        end
        tbl.css('.info2 p span a').each do |a|
            data['url'] = a.attribute('href').value
            data['title'] = data['title'] + " " + a.inner_html.strip
        end

        tbl.css('.info2 p').each do |p|
            text = p.inner_html
            starts = text.index('更新日')
            ends = text.index('<span', starts)
            if starts >= 0 && ends > starts then
                data['date'] = p.inner_html[starts, ends - starts].strip
                break
            end
        end

        data['banner_url'] = "https://static.syosetu.com/view/images/user_logo.gif?mpc5l6"
        data['official_site'] = "小説家になろう"

        if data.key?('title') then
            datas.push(data)
        end 
    end
end

files = Dir.glob('./data/html/*.html')
all_items = []
files.each do |f|
    if f.include?("ch.nicovideo.jp") then
        # ニコニコアニメチャンネルページ
        items = scrape_niconico_anime(f)
        all_items.concat(items)
    end
    if f.include?("ncode.syosetu.com") then
        # 小説家になろう小説一覧ページ
   #     items = scrape_narou(f)
    #    all_items.concat(items)
    end
end
