require 'open-uri'
require 'nokogiri'
require "json"
require 'securerandom'
require "fileutils"

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

def downloadAsPublicImage(url)
    publicImageURL = "/img/" + SecureRandom.hex(8) + ".png"
    download(url,  "./data" + publicImageURL)
    return publicImageURL
end

def scrape_niconico_anime(path, datas)
    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    lis = doc.css('.video.cfix.selected')
    lis.each do |li|
        data = {}
        inputs = li.css('input')
        inputs.each do |input|
            name = input.attribute('name').value
            value = input.attribute('value').value
            if name == "thumbnail_url" then
                data["thumbnail_url_raw"] = value
                newURL = downloadAsPublicImage(data["thumbnail_url_raw"])
                data["thumbnail_url"] = newURL
            else
                data[name] = value
            end
        end
        data["url"] = "http://www.nicovideo.jp/watch/" + li.attribute('id').value.split('_')[2]
        data['official_site'] = "ニコニコ動画"
        data['date'] = data['start_time'] 
        if data.key?('title') then
            datas.push(data)
        end 
    end
end

def scrape_syosetu(path, datas)
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

def scrape_comic_walker(path, datas)
    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    aTags = doc.css('.tileList a')
    aTags.each do |a|
        data = {}
        data["url"] = "https://comic-walker.com" + a.attribute("href").value
        data["title"] = a.css('h2 span')[0].inner_html.strip
        img = a.css('.pic img')[0]
        if img then
            data["thumbnail_url_raw"] = img.attribute("src").value
            newURL = downloadAsPublicImage(data["thumbnail_url_raw"])
            data["thumbnail_url"] = newURL
        end
        data['official_site'] = "Comic Walker"
        if data.key?('title') then
            datas.push(data)
        end 
    end

end

def scrape_youtube_playlist(path, datas)
    charset = 'utf-8'
    html = File.open(path) do |f| f.read end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    trs = doc.css('.pl-video.yt-uix-tile')
    trs.each do |tr|
        data = {}
        data["url"] = "https://www.youtube.com/watch?v=" + tr.attribute("data-video-id").value
        data["title"] = tr.attribute("data-title").value

        img = tr.css('img')[0]
        if img then
            data["thumbnail_url"] = img.attribute("data-thumb").value
        end
        if data.key?('title') then
            datas.push(data)
        end 
    end

end

def checkArgv(flg)
    return ARGV.include?('--all') || ARGV.include?(flg)
end

datas = []
if checkArgv('--video') then
  scrape_niconico_anime("./data/html/niconico/niconico_anime.html", datas)
  scrape_youtube_playlist("./data/html/youtube/lovelive-sunshine2.html", datas)
end

if checkArgv('--comic') then
    scrape_comic_walker("./data/html/comic-walker/contents-list.html", datas)
end

if checkArgv('--books') then
    scrape_syosetu("./data/html/syosetu/isnoticelist.html", datas)
end

puts "[" + datas.map{|d| JSON.pretty_generate(d) }.join(',') + "]"
