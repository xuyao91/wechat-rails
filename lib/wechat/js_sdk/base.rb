module Wechat::JsSdk
  class Base
  	attr_reader :timestamp, :noncestr, :client, :access_token, :url

  	def initialize(client, access_token, url)
  	  @client = client
  	  @access_token = access_token
  	  @timestamp = create_timestamp
  	  @noncestr = create_nonce_str
  	  @url = url
  	end	

  	def config 
  	  {
  	  	noncestr: noncestr,
        timestamp: timestamp,
        signature: sign
      }
  	end	

  	def sign
      Digest::SHA1.hexdigest sign_params_by_dict_sort(sign_params)
  	end	

  	private

  	def sign_params
  	  {
  	  	noncestr: noncestr,
        timestamp: timestamp,
        jsapi_ticket: ticket,
        url: url
      }
  	end	

  	def sign_params_by_dict_sort **params
  	  params.sort.to_h.to_query
  	end	

  	def create_timestamp
  	  Time.now.to_i
  	end
  	
  	def create_nonce_str length=16
  	  chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      str = ""
      length.times{ str += chars[rand(chars.length)] }
      str
  	end	
  end	
end	