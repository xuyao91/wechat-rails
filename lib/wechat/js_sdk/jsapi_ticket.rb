module Wechat::JsSdk 
  class JsapiTicket < Base 
  	attr_reader :jsapi_ticket_data, :jsapi_ticket_file

  	def initialize(client, access_token, jsapi_ticket_file, url)
  	  @jsapi_ticket_file = jsapi_ticket_file
  	  super(client, access_token, url)
  	end	

  	def ticket
  	  begin
        @jsapi_ticket_data ||= read_ticket
       rescue 
         self.refresh
      end
      return valid(@jsapi_ticket_data)	
  	end	

  	def refresh
  	  response = client.get("ticket/getticket", params: { access_token: access_token.token, type: "jsapi"})
      File.open(jsapi_ticket_file, 'w'){|f| f.write(response.merge!(expired_at: expired_at).to_json)} if valid(response)
      return @jsapi_ticket_data = response
  	end	

  	private

  	def valid jsapi_ticket_data
  	  ticket = jsapi_ticket_data["ticket"] || jsapi_ticket_data[:ticket]
      raise "Response didn't have ticket" if  ticket.blank?
      return ticket
  	end	

  	def read_ticket
      jsapi_ticket_data = JSON.parse(File.read(jsapi_ticket_file))
      return self.refresh if expire? jsapi_ticket_data
      return jsapi_ticket_data
  	end	

  	def expired_at 
      (Time.now.to_i + 7200) - 10
    end  

    def expire? token_data
      Time.now.to_i >= token_data["expired_at"].to_i
    end 
  end	
end