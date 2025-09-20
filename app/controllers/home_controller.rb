class HomeController < ApplicationController
  helper_method :current_user, :current_session
  include MoodHelper

  def current_user
    # Demo: Use URL parameter ?as=email to switch users
    User.find_by(email: params[:as]) || User.first
  end

  def current_session
    @current_session ||= begin
      session_id = session[:llm_session_id]
      s = session_id && LlmSession.find_by(id: session_id, user_id: current_user.id)
      s ||= LlmSession.create!(user: current_user, channel: :app, purpose: :faq, started_at: Time.current)
      session[:llm_session_id] = s.id
      s
    end
  end

  def index
    if current_user.nil?
      redirect_to onboarding_path, alert: "Please create user data first"
      return
    end

    @assignments = current_user.task_assignments.includes(:onboarding_task).order("task_assignments.id")
    @total = @assignments.count
    @done = @assignments.select(&:done?).count
    @progress = @total.zero? ? 0 : ((@done.to_f / @total) * 100).round
    @messages = current_session.llm_messages.order(:created_at)
    @mood_checkins = current_user.mood_checkins.order(created_at: :desc).limit(5)

    # Get happiness wallet data
    @happiness_wallet = current_user.happiness_wallet || current_user.create_happiness_wallet!(
      current_points: 0,
      lifetime_points: 0,
      level: 1,
      multiplier: 1.0,
      last_calculated_at: Time.current
    )

    # Calculate mood data using moving average of last 3 check-ins
    recent_moods = current_user.mood_checkins.order(created_at: :desc).limit(3).pluck(:score)

    if recent_moods.any?
      # Calculate weighted moving average (more recent = higher weight)
      weights = [ 0.5, 0.3, 0.2 ] # Most recent gets highest weight
      weighted_sum = recent_moods.each_with_index.sum { |score, index| score * (weights[index] || 0) }
      total_weight = weights[0, recent_moods.length].sum
      @mood_score = (weighted_sum / total_weight).round(1)
    else
      @mood_score = 3.0 # Default neutral mood
    end

    # Calculate trend based on recent moods
    if recent_moods.length >= 2
      recent_avg = recent_moods[0, 2].sum / 2.0
      older_avg = recent_moods.length >= 3 ? recent_moods[2] : 3.0
      @mood_trend = recent_avg > older_avg ? "up" : "flat"
    else
      @mood_trend = "flat"
    end

    # Mood label based on average score
    @mood_label = case @mood_score
    when 0..1.5 then "low"
    when 1.5..2.5 then "tense"
    when 2.5..3.5 then "stable"
    when 3.5..4.5 then "fresh"
    else "energetic"
    end
  end

  def create_message
    puts "hello"
    puts params
    # Create user message
    user_msg = current_session.llm_messages.create!(
      role: :user,
      content: params[:message].to_s,
      meta: { lang: "zh-TW" }
    )

    # Call LLM
    reply_text, reply_meta = Llm::Client.reply(user: current_user, session: current_session, message: user_msg)

    # Create assistant message
    assistant_msg = current_session.llm_messages.create!(
      role: :assistant,
      content: reply_text,
      meta: reply_meta
    )

    respond_to do |format|
      format.html { redirect_to root_path(as: params[:as]) }
      format.json {
        render json: {
          success: true,
          message: {
            content: assistant_msg.content,
            meta: assistant_msg.meta
          }
        }
      }
    end
  end
end
