#constants
DIR_CONFIG = '../../config/'
DIR_IMAGE  = '../../app/assets/images/girls/'
URL_BASE   = 'http://adult.likevideo.jp/actorRanking/?p='

#rails config
require "#{DIR_CONFIG}boot.rb"
require "#{DIR_CONFIG}environment.rb"

#standard libraries
require 'open-uri'
require 'fileutils'
require 'time'

#bundler
require 'bundler'
Bundler.require


class GirlsProfile
  def initialize()
    @name = nil
    @name_hira = nil
    @name_alpha = nil
    @birthday = nil
    @tall = nil
    @bust = nil
    @west = nil
    @hip = nil
    @hometown = nil
    @image_path = nil
  end

  def GirlsProfile.setDatabase(dbPath)
    @@database = dbPath
    #YAMLの読み込み：PATHは環境によって変更
    dbconfig = YAML.load_file(@@database)['development']

    #DBへの接続
    ActiveRecord::Base.establish_connection(dbconfig)
  end
  def setGirls()
    #あとはお馴染みの・・・
    girls = nil
    if !Girl.find_by(name:@name)
      girls = Girl.create(name:@name,
                          name_hira:@name_hira,
                          name_alpha:@name_alpha,
                          birthday:@birthday,
                          tall:@tall,
                          bust:@bust,
                          west:@west,
                          hip:@hip,
                          hometown:@hometown,
                          image_path:@image_path)
    end
  end
  def setName(nameString)
    string_reg = Regexp.new("（.*?）")
    @name = nameString.gsub(string_reg,'').to_s
    string_reg = Regexp.new("(.*（|）.*)")
    @name_hira = nameString.gsub(string_reg,'').to_s
    @name_alpha = Romaji.kana2romaji @name_hira
  end
  def setBorn(bornString)
    birth_str = bornString.gsub(Regexp.new("生年月日：|日"),'').to_s
    birth_str = birth_str.gsub(Regexp.new("年|月"),'-').to_s
    birth_array = birth_str.split('-')
    if birth_str != 'ー' && Date.valid_date?(birth_array[0].to_i,birth_array[1].to_i,birth_array[2].to_i)
      @birthday = DateTime.parse(birth_str)
    end
  end
  def setTall(tallString)
    tall = tallString.gsub(Regexp.new("身長：|cm"),'').to_s
    if tall != 'ー'
      @tall = tall.to_i
    end
  end
  def setSize(sizeString)
    size = sizeString.gsub(Regexp.new("サイズ："),'').to_s
    size = size.gsub(Regexp.new("B|W|H"),' ').to_s
    if size != 'ー'
      size_array = size.split(' ')
      @bust = size_array[0].to_i
      @west = size_array[1].to_i
      @hip  = size_array[2].to_i
    end
  end
  def setHome(homeString)
    hometown = homeString.gsub(Regexp.new("出身地："),'').to_s
    if hometown != 'ー'
      @hometown = hometown
    end

  end
  def setImageUrl(urlString)
    @image_url = urlString
  end
  def setImage()
    if @image_url && @name
      @image_path = save_image()
    end
  end

  private
    def save_image()
      # ready filepath
      # fileName = File.basename(url)
      extention = File.extname(@image_url)
      dirName = DIR_IMAGE
      filePath = dirName + @name_alpha + extention
      puts filePath

      # create folder if not exist
      FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

      # write image adata
      open(filePath, 'wb') do |output|
        open(@image_url) do |data|
          output.write(data.read)
        end
      end
      return filePath
    end
end


GirlsProfile.setDatabase("#{DIR_CONFIG}database.yml")
index = 0
loop{
  # スクレイピング先のURL
  index += 1
  url = URL_BASE + index.to_s

  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

    if !doc.at_css('div.actor_result')
      puts "end"
      break
    end

  # タイトルを表示
  p doc.title
  doc.css('div.actor_result').each do |actor|
    objGirls = GirlsProfile.new()
    image_url = actor.css('.thumbnail_area img').attribute('src').value.strip
    objGirls.setImageUrl(image_url)

    actor.css('.description_area p').each do |description|

      desc_string = description.inner_text.strip.to_s
      if description.attribute('class').to_s == 'title'
        objGirls.setName(desc_string)
      else
        case desc_string
        when Regexp.new("生年月日")
          objGirls.setBorn(desc_string)
        when Regexp.new("身長")
          objGirls.setTall(desc_string)
        when Regexp.new("サイズ")
          objGirls.setSize(desc_string)
        when Regexp.new("出身地")
          objGirls.setHome(desc_string)
        end
      end
    end
    objGirls.setImage()
    objGirls.setGirls()
  end
}
