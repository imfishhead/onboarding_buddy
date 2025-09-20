module Llm
  class Client
    # 之後你同學串真實 LLM API 時，只要改這支就行
    def self.reply(user:, session:, message:)
      q = message.content

      # ---- 假邏輯：關鍵字決定回答內容與meta ----
      if q.include?("通勤") || q.include?("交通")
        text = "你可以在 HR Portal → 交通服務 → 通勤車申請 找到流程；如需地點路線，我可以再提供。"
        meta = { rag: { doc_ids: [ 101 ], chunk_ids: [ 1, 2 ], confidence: 0.92 }, intent: "policy_faq", topics: [ "commute" ] }
      elsif q.include?("報帳") || q.include?("費用")
        text = "報帳流程：登入 ERP → 費用報銷 → 上傳單據 → 主管審核 → 財務撥款。"
        meta = { rag: { doc_ids: [ 102 ], chunk_ids: [ 4 ], confidence: 0.88 }, intent: "policy_faq", topics: [ "expense" ] }
      else
        text = "我懂你的焦慮。如果願意，先說說你卡在哪一步？我可以一步一步帶你做。"
        meta = { intent: "emotion_support", topics: [ "emotion" ] }
      end
      [ text, meta ]
    end
  end
end
