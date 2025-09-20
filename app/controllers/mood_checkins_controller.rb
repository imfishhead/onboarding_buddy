class MoodCheckinsController < ApplicationController
  helper_method :current_user

  def current_user
    User.find_by(email: params[:as]) || User.first
  end

  def create
    mc = current_user.mood_checkins.create!(score: params[:score].to_i, note: params[:note])

    # 簡單打分：1→-2, 2→-1, 3→+1, 4→+2, 5→+3
    delta = { 1=>-2, 2=>-1, 3=>1, 4=>2, 5=>3 }[mc.score] || 0
    Happiness::Accrual.call(user: current_user, source: mc, delta:, reason: "心情打卡", payload: { score: mc.score })

    # 低分補償小確幸 +2
    if mc.score <= 2
      trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :low_mood, payload: { score: mc.score })
      Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "低分補償小確幸")
    end

    redirect_back fallback_location: root_path(as: params[:as]), notice: "已完成心情打卡"
  end
end
