module MoodHelper
  def mood_emoji(score)
    case score
    when 1 then "😢"
    when 2 then "😐"
    when 3 then "😊"
    when 4 then "😄"
    when 5 then "🤩"
    else "😐"
    end
  end

  def mood_description(score)
    case score
    when 1 then "心情不太好"
    when 2 then "心情普通"
    when 3 then "心情不錯"
    when 4 then "心情很好"
    when 5 then "心情超棒"
    else "心情普通"
    end
  end

  def format_mood_date(date)
    now = Time.current
    if date.to_date == now.to_date
      "今天"
    elsif date.to_date == (now - 1.day).to_date
      "昨天"
    elsif date.to_date == (now - 2.days).to_date
      "前天"
    elsif date.year == now.year
      date.strftime("%m月%d日")
    else
      date.strftime("%Y年%m月%d日")
    end
  end

  def format_mood_time(date)
    date.in_time_zone("Asia/Taipei").strftime("%H:%M")
  end
end
