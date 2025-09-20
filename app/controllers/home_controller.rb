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
  end

  def create_message
    # Create user message
    user_msg = current_session.llm_messages.create!(
      role: :user,
      content: params[:message].to_s,
      meta: { lang: "zh-TW" }
    )

    # Call LLM
    reply_text, reply_meta = Llm::Client.reply(user: current_user, session: current_session, message: user_msg)

    # Create assistant message
    current_session.llm_messages.create!(
      role: :assistant,
      content: reply_text,
      meta: reply_meta
    )

    redirect_to root_path(as: params[:as])
  end
end
