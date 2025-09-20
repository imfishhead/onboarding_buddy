class My::MoodCheckinsController < ApplicationController
  helper_method :current_user
  def current_user
    User.find_by(email: params[:as]) || User.first
  end

  def create
    mc = current_user.mood_checkins.create!(score: params[:score].to_i, note: params[:note])

    # 簡單打分：1→-2, 2→-1, 3→+1, 4→+2, 5→+3
    delta = { 1=>-2, 2=>-1, 3=>1, 4=>2, 5=>3 }[mc.score] || 0
    Happiness::Accrual.call(user: current_user, source: mc, delta:, reason: "Mood check-in", payload: { score: mc.score })

    # 低分補償小確幸 +2
    if mc.score <= 2
      trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :low_mood, payload: { score: mc.score })
      Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "Low mood compensation")
    end

    # 生成微回饋和建議
    feedback_data = Mood::FeedbackService.generate_feedback(mc.score, current_user)

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path(as: params[:as]), notice: "已完成心情打卡" }
      format.json { render json: {
        success: true,
        message: "Mood check-in completed",
        feedback: feedback_data[:feedback],
        suggestions: feedback_data[:suggestions],
        show_resources: feedback_data[:show_resources]
      } }
    end
  end
end
