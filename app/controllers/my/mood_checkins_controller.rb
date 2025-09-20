# encoding: UTF-8
# frozen_string_literal: true

class My::MoodCheckinsController < ApplicationController
  helper_method :current_user

  def current_user
    User.find_by(email: params[:as]) || User.first
  end

  def create
    mc = current_user.mood_checkins.create!(score: params[:score].to_i, note: params[:note])
    delta = { 1=>-2, 2=>-1, 3=>1, 4=>2, 5=>3 }[mc.score] || 0
    Happiness::Accrual.call(user: current_user, source: mc, delta:, reason: "心情打卡", payload: { score: mc.score })
    if mc.score <= 2
      trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :low_mood, payload: { score: mc.score })
      Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "低分補償小確幸")
    end

    feedback = MoodFeedback.generate(mc.score)

    # Check for support suggestions after mood checkin
    support_data = SupportSuggestion.check_and_suggest(current_user)

    if support_data
      session[:support_suggestions] = support_data
    end

    # Check for achievements and streak updates
    achievements = ConsistencyTracker.check_achievements(current_user) || []
    streak_info = ConsistencyTracker.streak_info(current_user)

    if achievements.any?
      session[:achievements] = achievements
    end

    session[:streak_info] = streak_info
    session[:energy_animation] = true

    redirect_back fallback_location: my_onboarding_path(as: params[:as]),
                  notice: feedback[:message]
  end
end
