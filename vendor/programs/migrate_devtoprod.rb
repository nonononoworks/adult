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

MovieDev.all.each do |moviedev|

  if MovieProd.find_by(id: moviedev.id)
    #update
    movieprod = MovieProd.find_by(moviedev.id)
  else
    #create
    movieprod = MovieProd.new(id: moviedev.id)
  end

  movieprod.url         = moviedev.url
  movieprod.embed       = moviedev.embed
  movieprod.title       = moviedev.title
  movieprod.description = moviedev.descriptio
  movieprod.image_path  = moviedev.image_path
  movieprod.plays       = moviedev.plays
  movieprod.created_at  = moviedev.created_at
  movieprod.updated_at  = moviedev.updated_at
  movieprod.save

end

