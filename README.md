# Anime Checker

アニメや小説やマンガの更新を検知してsrc/output/diff.jsonに出力する

* ニコニコ動画のアニメチャンネル
* 小説家になろう

の作品ごとのページをクロール・スクレイプする


クロール結果は `./src/crawled` 以下に保存される
スクレイプ結果は `./src/scraped` 以下に保存される

# How to use

Windows:
```
cd ./src
bundle install
cd ../
./win.sh
```

Mac:
```
cd ./src
bundle install
cd ../
./mac.sh
```

If succeeded, ./src/output/updates.json will opens with your default application.
