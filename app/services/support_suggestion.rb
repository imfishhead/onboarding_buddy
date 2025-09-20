# encoding: UTF-8
# frozen_string_literal: true

class SupportSuggestion
  def self.check_and_suggest(user)
    recent_moods = user.mood_checkins.where(created_at: 7.days.ago..Time.current)
                      .order(:created_at)
                      .pluck(:score)

    return nil unless should_trigger_support?(recent_moods)

    # Call LLM for personalized suggestions
    suggestions = generate_suggestions(user, recent_moods)

    {
      triggered: true,
      reason: analyze_pattern(recent_moods),
      suggestions: suggestions
    }
  end

  private

  def self.should_trigger_support?(recent_moods)
    return false if recent_moods.length < 3

    # Check for consecutive low scores (1-2)
    recent_moods.last(3).all? { |score| score <= 2 }
  end

  def self.analyze_pattern(recent_moods)
    if recent_moods.last(3).all? { |score| score == 1 }
      "連續三天心情低落"
    elsif recent_moods.last(3).all? { |score| score <= 2 }
      "連續三天心情不佳"
    else
      "最近心情波動較大"
    end
  end

  def self.generate_suggestions(user, recent_moods)
    # For now, return static suggestions based on pattern
    # In production, this would call your LLM API
    case recent_moods.last(3).sum
    when 3..4
      [
        {
          title: "放鬆呼吸練習",
          description: "5分鐘的深呼吸練習，幫助緩解壓力",
          type: "breathing",
          action: "開始練習",
          url: "#breathing-exercise"
        },
        {
          title: "HR 小聚會",
          description: "這週五下午有新人交流聚會，你可能會喜歡參加",
          type: "social",
          action: "了解詳情",
          url: "#hr-meetup"
        },
        {
          title: "員工協助方案",
          description: "24小時心理諮詢熱線，隨時可以聊聊",
          type: "support",
          action: "查看資源",
          url: "#eap"
        }
      ]
    when 5..6
      [
        {
          title: "正念冥想",
          description: "10分鐘的冥想練習，幫助穩定情緒",
          type: "mindfulness",
          action: "開始冥想",
          url: "#meditation"
        },
        {
          title: "同事咖啡時間",
          description: "找個同事一起喝咖啡，聊聊工作感受",
          type: "social",
          action: "安排時間",
          url: "#coffee-chat"
        }
      ]
    else
      [
        {
          title: "工作節奏調整",
          description: "試試番茄工作法，25分鐘專注 + 5分鐘休息",
          type: "productivity",
          action: "學習方法",
          url: "#pomodoro"
        }
      ]
    end
  end
end
