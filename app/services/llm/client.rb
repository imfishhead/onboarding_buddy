require "net/http"
require "json"
require "uri"

module Llm
  class Client
    API_BASE_URL = "http://127.0.0.1:8000"

    def self.reply(user:, session:, message:)
      max_retries = 3

      (0...max_retries).each do |attempt|
        begin
          # 準備 API 請求參數
          request_body = {
            user_query: message.content,
            session_id: session.id.to_s,
            user_ctx: {
              dept: "HR"
            }
          }

          puts "=== LLM Client Request (Attempt #{attempt + 1}) ==="
          puts request_body.to_json

          # 發送 HTTP POST 請求到 dockerized API
          uri = URI("#{API_BASE_URL}/route")

          # 每次重試都創建新的 HTTP 連接
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = 10
          http.read_timeout = 30
          http.use_ssl = false

          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request["Accept"] = "application/json"
          request["User-Agent"] = "Rails-App/1.0"
          request.body = request_body.to_json

          puts "=== Sending Request ==="
          puts "URL: #{uri}"

          response = http.request(request)

          puts "=== LLM API Response ==="
          puts "Status: #{response.code}"
          puts "Body: #{response.body}"

          if response.code == "200"
            response_data = JSON.parse(response.body)
            text = response_data["answer"] || response_data["message"] || response_data["text"] || "抱歉，我無法處理您的請求。"
            meta = response_data["meta"] || {}
            return [ text, meta ]
          elsif response.code == "502" && attempt < max_retries - 1
            puts "=== Retrying due to 502 error (attempt #{attempt + 1}/#{max_retries}) ==="
            sleep(1) # 等待1秒後重試
            next
          else
            Rails.logger.error "LLM API Error: #{response.code} - #{response.body}"
            return [ "抱歉，服務暫時無法使用，請稍後再試。", { error: "api_error", status: response.code } ]
          end
        rescue StandardError => e
          if attempt < max_retries - 1
            puts "=== Retrying due to exception: #{e.message} (attempt #{attempt + 1}/#{max_retries}) ==="
            sleep(1)
            next
          else
            Rails.logger.error "LLM Client Error: #{e.message}"
            return [ "抱歉，服務暫時無法使用，請稍後再試。", { error: "client_error", message: e.message } ]
          end
        ensure
          http.finish if http && http.started?
        end
      end

      # 如果所有重試都失敗了
      [ "抱歉，服務暫時無法使用，請稍後再試。", { error: "max_retries_exceeded" } ]
    end
  end
end
