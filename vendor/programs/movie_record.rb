#constants
DIR_CONFIG = '../../config/'
DIR_IMAGE  = '../../app/assets/images/movies/'
URL_BASE   = 'http://jp.xvideos.com'
URL_SEARCH = '/?k=japanese&p='
URL_SORT   = '&sort=rating'

#rails config
require "#{DIR_CONFIG}boot.rb"
require "#{DIR_CONFIG}environment.rb"

#external file
require './translate.rb'

#standard libraries
require 'open-uri'
require 'fileutils'
require 'time'
require 'net/http'
require 'rexml/document'
require 'rubygems'
require 'RMagick'

#bundler
require 'bundler'
Bundler.require

class MovieData
    @@width = 300
    @@height = 200
  def initialize()

    @url = nil
    @embed = nil
    @title = nil
    @description = nil
    @image_path = nil

    @doc = nil
    @image_url = nil
    @tags = []
    @movies = nil
  end
  def MovieData.setDatabase(dbPath)
    @@database = dbPath
    #YAMLの読み込み：PATHは環境によって変更
    dbconfig = YAML.load_file(@@database)['development']

    #DBへの接続
    ActiveRecord::Base.establish_connection(dbconfig)

    @@trans = Translation.new
  end
  def setMovie()
    #あとはお馴染みの・・・
    movies = nil
    @movies = Movie.find_by(url:@url)
    if !@movies
      @movies = Movie.create(url:@url)
    end
    @movies.embed = @embed
    @movies.title = @title
    @movies.description = @description
  end
  def setUrl(url_str)
    @url = url_str
  end
  def setTitle(title_str)
    @title = translate(title_str,TranslateTitle)
  end
  def setEmbed(charset)
    embed = @doc.css('#tabEmbed input').attribute('value').value.to_s
    tempDoc = Nokogiri::HTML.parse(embed, nil, charset)
    @embed = tempDoc.css('iframe').attribute('src').value.to_s
  end
  def setTag()
    @doc.css('#video-tags li').each do |tag|
      tagStr = tag.css('a').inner_text.strip.to_s
      if tagStr
        @tags = @tags.push(tagStr)
      end
    end
    @tags.each do |word|
      word = translate(word,TranslateTag)
      if !@movies.tags.find_by(name:word)
        @movies.tag_list.add(word)
      end
    end
    @movies.save
  end
  def setImageUrl(imageStr)
    @image_url = imageStr
  end

  def parseDocument()
    charset = nil
    html = open(@url) do |f|
      charset = f.charset # 文字種別を取得
      f.read # htmlを読み込んで変数htmlに渡す
    end

    # htmlをパース(解析)してオブジェクトを生成
    @doc = Nokogiri::HTML.parse(html, nil, charset)
  end

  def setImage()
    if @image_url && @movies
      puts @movies.id
      puts @image_path = save_image()
      resize_image()
      @movies.image_path = @image_path
      @movies.save
    end
  end

  private
    def save_image()
      # ready filepath
      fileName = @movies.id.to_s + File.extname(@image_url)
      dirName = DIR_IMAGE
      filePath = dirName + fileName

      # create folder if not exist
      FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

      # write image adata
      open(filePath, 'wb') do |output|
        open(@image_url) do |data|
          output.write(data.read)
        end
      end

      return fileName
    end
    def resize_image()
      #Resize
      filePath = DIR_IMAGE + @image_path.to_s
      original = Magick::Image.read(filePath).first

      if original
        image = original.resize(@@width, @@height)
        image.write(filePath)
      end
    end
    def translate(word,table)

      record = table.find_by(english:word)
      if record
        jpWord = record.japanese
      else
        jpWord = @@trans.trans(word)
        if jpWord
          table.create(english:word,japanese:jpWord)
        else
          puts 'translation failed'
        end
      end
      return jpWord
    end
end

MovieData.setDatabase("#{DIR_CONFIG}database.yml")
index = 0
loop{
  # スクレイピング先のURL

  url = URL_BASE + URL_SEARCH + index.to_s + URL_SORT
  index += 1

  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  # htmlをパース(解析)してオブジェクトを生成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  if !doc.at_css('div.thumbBlock')
    puts "end"
    break
  end

  # タイトルを表示
  p doc.title
  doc.css('div.thumbBlock').each do |thumbnail|
    objMovie = MovieData.new()

    movie_url = URL_BASE + thumbnail.css('.thumb a').attribute('href').value.strip.to_s
    objMovie.setUrl(movie_url)

    movie_title = thumbnail.css('.thumbInside p a').inner_text.strip.to_s
    objMovie.setTitle(movie_title)

    image_url = thumbnail.css('.thumb img').attribute('src').value.strip
    objMovie.setImageUrl(image_url)

    objMovie.parseDocument()

    objMovie.setEmbed(charset)

    objMovie.setMovie()

    objMovie.setImage()

    #objMovie.setDescription()

    objMovie.setTag()

    #objMovie.instance_variables.each do |variable|
    #  if variable.to_s == '@url' || variable.to_s == '@embed' || variable.to_s == '@image_path'
    #    puts objMovie.instance_variable_get(variable)
    #  end
    #end

  end
}
