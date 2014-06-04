DIR_CONFIG = '../../config/'

#rails config
require "#{DIR_CONFIG}boot.rb"
require "#{DIR_CONFIG}environment.rb"


#bundler
require 'bundler'
Bundler.require


class DevelopmentDB < ActiveRecord::Base
  self.abstract_class = true

  @@database = "#{DIR_CONFIG}database.yml"
  #YAMLの読み込み：PATHは環境によって変更
  dbconfig = YAML.load_file(@@database)['development']

  #DBへの接続
  #ActiveRecord::Base.establish_connection(dbconfig)
  establish_connection(dbconfig)

end

class ProductionDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(
             adapter: 'postgresql',
             database: 'dfi4ln7sts482u',
             host: 'ec2-54-225-243-113.compute-1.amazonaws.com',
             username: 'gnwqtitalyovqu',
             password: 'i2pkTHpicV5bfIVJOQTMKszu9C',
             sslmodel: 'require')
end

class MovieDev < DevelopmentDB
  self.table_name = :movies
end

class MovieProd < ProductionDB
  self.table_name = :movies
end

class TagDev < DevelopmentDB
  self.table_name = :tags
end

class TagProd < ProductionDB
  self.table_name = :tags
end

class TaggingDev < DevelopmentDB
  self.table_name = :taggings
end

class TaggingProd < ProductionDB
  self.table_name = :taggings
end

class GirlDev < DevelopmentDB
  self.table_name = :girls
end

class GirlProd < ProductionDB
  self.table_name = :girls
end

MovieDev.all.each do |moviedev|

  if MovieProd.find_by(id: moviedev.id)
    #update
    movieprod = MovieProd.find_by(id: moviedev.id)
  else
    #create
    movieprod = MovieProd.new(id: moviedev.id)
  end

  movieprod.url         = moviedev.url
  movieprod.embed       = moviedev.embed
  movieprod.title       = moviedev.title
  movieprod.description = moviedev.description
  movieprod.image_path  = moviedev.image_path
  movieprod.plays       = moviedev.plays
  movieprod.created_at  = moviedev.created_at
  movieprod.updated_at  = moviedev.updated_at
  movieprod.save
  puts movieprod.url

end

TagDev.all.each do |tagdev|

  if TagProd.find_by(id: tagdev.id)
    #update
    tagprod = TagProd.find_by(id: tagdev.id)
  else
    #create
    tagprod = TagProd.new(id: tagdev.id)
  end

  tagprod.name            = tagdev.name
  tagprod.taggings_count  = tagdev.taggings_count
  tagprod.save
  puts tagprod.name
end

TaggingDev.all.each do |taggingdev|

  if TaggingProd.find_by(id: taggingdev.id)
    #update
    taggingprod = TaggingProd.find_by(id: taggingdev.id)
  else
    #create
    taggingprod = TaggingProd.new(id: taggingdev.id)
  end

  taggingprod.tag_id        = taggingdev.tag_id
  taggingprod.taggable_id   = taggingdev.taggable_id
  taggingprod.taggable_type = taggingdev.taggable_type
  taggingprod.tagger_id     = taggingdev.tagger_id
  taggingprod.tagger_type   = taggingdev.tagger_type
  taggingprod.context       = taggingdev.context
  taggingprod.created_at    = taggingdev.created_at
  taggingprod.save

  puts taggingprod.tag_id
end

GirlDev.all.each do |girldev|

  if GirlProd.find_by(id: girldev.id)
    #update
    girlprod = GirlProd.find_by(id: girldev.id)
  else
    #create
    girlprod = GirlProd.new(id: girldev.id)
  end

  girlprod.name       = girldev.name
  girlprod.name_hira  = girldev.name_hira
  girlprod.name_alpha = girldev.name_alpha
  girlprod.birthday   = girldev.birthday
  girlprod.tall       = girldev.tall
  girlprod.bust       = girldev.bust
  girlprod.west       = girldev.west
  girlprod.hip        = girldev.hip
  girlprod.hometown   = girldev.hometown
  girlprod.image_path = girldev.image_path
  girlprod.created_at = girldev.created_at
  girlprod.updated_at = girldev.updated_at
  girlprod.save

  puts girlprod.name
end

puts 'OK'

