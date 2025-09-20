class My::OnboardingController < ApplicationController
  layout "mobile"
  helper_method :current_user

  # Demo 用：用 URL 參數 ?as=alice 切換使用者
  def current_user
    User.find_by(email: params[:as].presence || "alice@tsmc.com") || User.first
  end

  def index
    @assignments = current_user.task_assignments.includes(:onboarding_task).order("task_assignments.id")
    @total = @assignments.count
    @done  = @assignments.select(&:done?).count
    @progress = @total.zero? ? 0 : ((@done.to_f / @total) * 100).round

    # 載入聊天訊息
    @current_session = begin
      session_id = session[:llm_session_id]
      s = session_id && LlmSession.find_by(id: session_id, user_id: current_user.id)
      s ||= LlmSession.create!(user: current_user, channel: :app, purpose: :faq, started_at: Time.current)
      session[:llm_session_id] = s.id
      s
    end
    @messages = @current_session.llm_messages.order(:created_at)
  end

  def complete
    assignment = current_user.task_assignments.find(params[:id])
    puts "a"
    assignment.update!(status: :done)
    # 小確幸 +2
    trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :task_done, payload: { task_id: assignment.onboarding_task_id })
    Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "Complete task small delight")
    redirect_to my_onboarding_path(as: params[:as]), notice: "Task completed, happiness energy added!"
  end
end
