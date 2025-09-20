class My::OnboardingController < ApplicationController
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
  end

  def complete
    assignment = current_user.task_assignments.find(params[:id])
    assignment.update!(status: :done)
    # 小確幸 +2
    trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :task_done, payload: { task_id: assignment.onboarding_task_id })
    Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "完成任務小確幸")
    redirect_to my_onboarding_path(as: params[:as]), notice: "任務完成，已加幸福能量！"
  end
end
