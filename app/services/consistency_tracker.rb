# encoding: UTF-8
# frozen_string_literal: true

class ConsistencyTracker
  def self.check_achievements(user)
    return [] unless user&.mood_checkins

    recent_checkins = user.mood_checkins.where(created_at: 7.days.ago..Time.current)
                         .order(:created_at)

    achievements = []

    begin
      # Check for 7-day streak
      if consecutive_days(recent_checkins) >= 7 && !user.achievements.exists?(achievement_type: "consistency", level: "gold")
        achievement = user.achievements.create!(
          achievement_type: "consistency",
          title: "堅持小徽章",
          description: "連續 7 天記錄心情！",
          emoji: "🏆",
          level: "gold"
        )
        achievements << achievement
      elsif consecutive_days(recent_checkins) >= 3 && !user.achievements.exists?(achievement_type: "consistency", level: "silver")
        achievement = user.achievements.create!(
          achievement_type: "consistency",
          title: "習慣養成中",
          description: "連續 #{consecutive_days(recent_checkins)} 天記錄心情！",
          emoji: "🌱",
          level: "silver"
        )
        achievements << achievement
      end

      # Check for first week completion
      if recent_checkins.count >= 5 && !user.achievements.exists?(achievement_type: "first_week")
        achievement = user.achievements.create!(
          achievement_type: "first_week",
          title: "新手成就",
          description: "完成第一週的心情記錄！",
          emoji: "⭐",
          level: "bronze"
        )
        achievements << achievement
      end
    rescue => e
      Rails.logger.error "Error creating achievements: #{e.message}"
      achievements = []
    end

    achievements
  end

  def self.consecutive_days(checkins)
    return 0 if checkins.empty?

    dates = checkins.map { |c| c.created_at.to_date }.uniq.sort.reverse
    consecutive = 1

    dates.each_cons(2) do |current, previous|
      if current == previous + 1.day
        consecutive += 1
      else
        break
      end
    end

    consecutive
  end

  def self.streak_info(user)
    recent_checkins = user.mood_checkins.where(created_at: 30.days.ago..Time.current)
                         .order(:created_at)

    current_streak = consecutive_days(recent_checkins)
    longest_streak = calculate_longest_streak(recent_checkins)

    {
      current: current_streak,
      longest: longest_streak,
      next_milestone: next_milestone(current_streak)
    }
  end

  private

  def self.calculate_longest_streak(checkins)
    return 0 if checkins.empty?

    dates = checkins.map { |c| c.created_at.to_date }.uniq.sort
    max_streak = 1
    current_streak = 1

    dates.each_cons(2) do |current, next_date|
      if next_date == current + 1.day
        current_streak += 1
        max_streak = [ max_streak, current_streak ].max
      else
        current_streak = 1
      end
    end

    max_streak
  end

  def self.next_milestone(current_streak)
    milestones = [ 3, 7, 14, 30, 60, 100 ]
    milestones.find { |m| m > current_streak } || nil
  end
end
