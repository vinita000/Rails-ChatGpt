class ChatgptService
  MAX_RETRIES = 3
  include HTTParty

  attr_reader :api_url, :options, :model, :message

  def initialize(message, model = 'gpt-3.5-turbo')
    api_key = Rails.application.credentials.chatgpt_api_key
    @options = {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{api_key}"
      }
    }
    @api_url = 'https://api.openai.com/v1/chat/completions'
    @message = message
    @model = model
  end

  def call
    retries = 0
    begin
      body = {
        model: model,
        messages: [{ role: 'user', content: message }]
      }

      response = HTTParty.post(api_url, body: body.to_json, headers: options[:headers], timeout: 50)
      raise response['error']['message'] unless response.code == 200

      response['choices'][0]['message']['content']
      
    rescue Net::ReadTimeout => e
      retries += 1
      retry if retries < MAX_RETRIES
      raise e, "Max retries exceeded"
    end
  end

  class << self
    def call(message, model = 'gpt-3.5-turbo')
      new(message, model).call
    end
  end
end