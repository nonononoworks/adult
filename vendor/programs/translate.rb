# -*- encoding: utf-8 -*-

require 'json'
require 'net/http'
require 'uri'
require 'openssl'
require 'rexml/document'

class Translation
  # プライマリアカウントキー see: https://datamarket.azure.com/account
  MS_TRANSLATOR_PRIMARY_KEY      = "u6kh7oD1e6/2MNMALn9EB/7Y+HiWGzhElRp8C+7fOGw"
  # クライアントID see: https://datamarket.azure.com/developer/applications/
  MS_TRANSLATOR_CLIENT_ID        = "AdultSite"
  # クライアントID see: 顧客の秘密
  MS_TRANSLATOR_CLIENT_SECRET    = "vf1uPysJXn33+6x7stDXtioSn4KzG2KdOXA0QazyXoQ="
  MS_TRANSLATOR_ACCESSTOKEN_URL  = "https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"
  MS_TRANSLATOR_SCOPE            = "http://api.microsofttranslator.com"
  MS_TRANSLATOR_URL              = "http://api.microsofttranslator.com/V2/Http.svc/Translate"
  MS_TRANSLATOR_GRANT_TYPE       = "client_credentials"

  def initialize
    @cache = {}
  end

  # POSTしてアクセストークンを取得する
  def getAccessTokenMessage
    response = nil

    Net::HTTP.version_1_2
    uri = URI.parse(MS_TRANSLATOR_ACCESSTOKEN_URL)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path)
    request.set_form_data({
      :client_id => MS_TRANSLATOR_CLIENT_ID,
      :client_secret => MS_TRANSLATOR_CLIENT_SECRET,
      :scope => MS_TRANSLATOR_SCOPE,
      :grant_type => MS_TRANSLATOR_GRANT_TYPE
      })

    response = https.request(request)

    if response.message == "OK"
      @updateTime = Time.now
      JSON.parse(response.body)
    else
      raise "access token acquisition failure"
    end

  end

  # キャッシュから、もしくはPOSTしてアクセストークンを取得する
  def getAccessToken(renew = false)
    renewJson = true

    if(@updateTime && @expiresIn)
      delta = Time.now - @updateTime
      if(delta <= @expiresIn.to_i - 10)
        renewJson = false
      end
    end

    if(renew)
     renewJson = true
    end

    # puts "info: renew access token" if renewJson
    @jsonResult = getAccessTokenMessage if renewJson
    @accessToken = @jsonResult["access_token"]
    @expiresIn = @jsonResult["expires_in"]

    return @accessToken
  end

  def existsTransCache(word)
    @cache.has_key?(word)
  end

  def setTransCache(word, resultWord)
    @cache[word] = resultWord
  end

  def getTransCache(word)
    @cache[word]
  end

  # wordを翻訳する
  def trans(word)
    if existsTransCache(word)
      return getTransCache(word)
    end
    access_token = getAccessToken

    Net::HTTP.version_1_2
    uri = URI.parse(MS_TRANSLATOR_URL)
    http = Net::HTTP.new(uri.host, uri.port)

    params = {
      :text => word,
      :from => "en",
      :to => "ja"
      }
    query_string = params.map{ |k,v|
      URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
    }.join("&")

    request = Net::HTTP::Get.new(uri.path + "?" + query_string)
    request['Authorization'] = "Bearer #{access_token}"

    response = http.request(request)

    result = nil
    # response.body
    # => <string xmlns="http://schemas.microsoft.com/2003/10/Serialization/">サンプル</string>
    if response.message == "OK"
      document = REXML::Document.new(response.body)
      result = document.root.text
      setTransCache(word, result)
    end

    result
  end

end

#puts "input English word ('!' to quit)"
#while true
#  print("(word or '!'): ")
#  word = gets.chomp
#  if word == "!"
#    break
#  end
#  puts " => " + trans.trans(word)
#end