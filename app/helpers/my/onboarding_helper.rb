# encoding: UTF-8
# frozen_string_literal: true

module My::OnboardingHelper
  def mood_trend_data(user, days = 7)
    return [] unless user&.mood_checkins

    end_date = Date.current
    start_date = end_date - (days - 1).days

    # Get mood checkins for the period
    checkins = user.mood_checkins.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                  .order(:created_at)

    # Create a hash of date => mood score
    mood_by_date = checkins.group_by { |c| c.created_at.to_date }
                          .transform_values { |checkins| checkins.last.score }

    # Fill in missing dates with nil
    trend_data = []
    (start_date..end_date).each do |date|
      score = mood_by_date[date]
      trend_data << {
        date: date,
        score: score,
        emoji: score ? mood_emoji(score) : nil,
        day_name: date.strftime("%a"),
        day_number: date.day
      }
    end

    trend_data
  end

  def mood_emoji(score)
    case score
    when 1 then "😢"
    when 2 then "☹️"
    when 3 then "😐"
    when 4 then "🙂"
    when 5 then "😄"
    else "❓"
    end
  end

  def mood_trend_summary(trend_data)
    return "還沒有心情記錄" unless trend_data&.any?

    scores = trend_data.map { |d| d[:score] }.compact
    return "還沒有心情記錄" if scores.empty?

    recent_trend = trend_data.last(3).map { |d| d[:score] }.compact

    if recent_trend.length >= 2
      if recent_trend.last > recent_trend.first
        "最近心情有上升趨勢 📈"
      elsif recent_trend.last < recent_trend.first
        "最近心情有點下滑 📉"
      else
        "最近心情保持穩定 📊"
      end
    else
      "繼續記錄心情變化 📝"
    end
  end
end
