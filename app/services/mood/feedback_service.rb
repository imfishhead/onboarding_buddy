module Mood
  class FeedbackService
    def self.generate_feedback(score, user)
      feedback = generate_personalized_feedback(score)
      suggestions = generate_suggestions(score, user)

      {
        feedback: feedback,
        suggestions: suggestions,
        show_resources: should_show_resources?(user)
      }
    end

    private

    def self.generate_personalized_feedback(score)
      case score
      when -1
        [
          "感覺你今天比較辛苦，沒關係的 💙",
          "可以多喝水休息一下～或許想找誰聊聊？",
          "每個人都會有低潮，你並不孤單 🌱",
          "要不要試試深呼吸，讓自己放鬆一下？"
        ].sample
      when 0
        [
          "感覺你在適應中，辛苦了 👍",
          "慢慢來，給自己一些時間 🌱",
          "適應新環境需要時間，你很棒了！",
          "今天可能有點累，好好休息一下吧"
        ].sample
      when 1
        [
          "保持這樣的心情，繼續加油！ ✨",
          "看起來你今天過得不錯呢！",
          "很好的狀態，保持下去！",
          "心情不錯，繼續保持這個節奏！"
        ].sample
      when 2
        [
          "你的好心情感染了我們！ 🌟",
          "看起來今天很棒呢！",
          "保持這個好心情！",
          "你的正能量滿滿的！"
        ].sample
      when 3
        [
          "你的正能量滿滿，繼續發光發熱！ 🚀",
          "太棒了！你的好心情很有感染力！",
          "今天看起來超棒的！",
          "你的快樂能量爆表了！"
        ].sample
      else
        "感謝你分享心情！"
      end
    end

    def self.generate_suggestions(score, user)
      suggestions = []

      if score <= 1
        suggestions << {
          type: "breathing",
          title: "放鬆呼吸練習",
          description: "請回到呼吸環，進行呼吸練習",
          action: nil
        }

        suggestions << {
          type: "social",
          title: "找人聊聊",
          description: "有時候和同事聊聊會讓心情好一些",
          action: "查看聯絡方式"
        }
      end

      if should_show_resources?(user)
        suggestions << {
          type: "hr_event",
          title: "HR 小聚會",
          description: "這週 HR 有小聚會，你可能會喜歡參加",
          action: "了解詳情"
        }

        suggestions << {
          type: "wellness",
          title: "員工健康資源",
          description: "公司提供各種健康支援資源",
          action: "查看資源"
        }
      end

      suggestions
    end

    def self.should_show_resources?(user)
      # 檢查是否連續三天低分 (1-2分)
      recent_checkins = user.mood_checkins
                           .where(created_at: 3.days.ago..Time.current)
                           .order(created_at: :desc)
                           .limit(3)

      return false if recent_checkins.count < 3

      recent_checkins.all? { |checkin| checkin.score <= 1 }
    end
  end
end
