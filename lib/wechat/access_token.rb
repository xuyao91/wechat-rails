module Wechat
  class AccessToken
    attr_reader :client, :appid, :secret, :token_file, :token_data

    def initialize(client, appid, secret, token_file)
      @appid = appid
      @secret = secret
      @client = client
      @token_file = token_file
    end

    def token
      begin
        @token_data ||= read_token
      rescue 
        self.refresh
      end
      return valid_token(@token_data)
    end

    def refresh
      data = client.get("token", params:{grant_type: "client_credential", appid: appid, secret: secret})
      File.open(token_file, 'w'){|f| f.write(data.merge(expires_at: expired_at).to_json)} if valid_token(data)
      return @token_data = data
    end

    def read_token
      token_data = JSON.parse(file.read(token_file))
      return self.refresh if expire? token_data
      return token_data  
    end  

    private 
    def valid_token token_data
      access_token = token_data["access_token"]
      raise "Response didn't have access_token" if  access_token.blank?
      return access_token
    end

    def expired_at 
      (Time.now.to_i + 7200) - 10
    end  

    def expire? token_data
      Time.now.to_i >= token_data["expired_at"].to_i
    end  

  end
end
