require "net/http"
require "json"
require "uri"

module Llm
  class Client
    API_BASE_URL = "http://localhost:8000"

    def self.reply(user:, session:, message:)
      begin
        # 準備 API 請求參數
        request_body = {
          user_query: message.content,
          session_id: session.id.to_s
          # user_ctx: {
          #   dept: user.department&.upcase
          # }
        }

        puts request_body.to_json

        # 發送 HTTP POST 請求到 dockerized API
        uri = URI("#{API_BASE_URL}/route")
        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = request_body.to_json

        puts request_body.to_json

        response = http.request(request)

        puts response.body

        if response.code == "200"
          response_data = JSON.parse(response.body)
          text = response_data["answer"] || response_data["message"] || "\u62B1\u6B49\uFF0C\u6211\u7121\u6CD5\u8655\u7406\u60A8\u7684\u8ACB\u6C42\u3002"
          meta = response_data["meta"] || {}
          [ text, meta ]
        else
          Rails.logger.error "LLM API Error: #{response.code} - #{response.body}"
          [ "抱歉，服務暫時無法使用，請稍後再試。", { error: "api_error", status: response.code } ]
        end
      rescue StandardError => e
        Rails.logger.error "LLM Client Error: #{e.message}"
        [ "抱歉，服務暫時無法使用，請稍後再試。", { error: "client_error", message: e.message } ]
      end
    end
  end
end
