class My::OnboardingController < ApplicationController
  helper_method :current_user

  # Demo: Use URL parameter ?as=alice to switch users
  def current_user
    User.find_by(email: params[:as].presence || "alice@tsmc.com") || User.first
  end

  def index
    if current_user.nil?
      redirect_to root_path, alert: "Please create user data first"
      return
    end

    @assignments = current_user.task_assignments.includes(:onboarding_task).order("task_assignments.id")
    @total = @assignments.count
    @done  = @assignments.select(&:done?).count
    @progress = @total.zero? ? 0 : ((@done.to_f / @total) * 100).round
  end

  def complete
    assignment = current_user.task_assignments.find(params[:id])

    # Check if we're completing or uncompleting
    if params[:status] == "done" || assignment.pending?
      # Complete the task
      assignment.update!(status: :done)
      # Small delight +2
      trigger = SmallDelightTrigger.create!(user: current_user, trigger_type: :task_done, payload: { task_id: assignment.onboarding_task_id })
      Happiness::Accrual.call(user: current_user, source: trigger, delta: 2, reason: "Task completion bonus")
      message = "Task completed, happiness points added!"
    else
      # Uncomplete the task
      assignment.update!(status: :pending)
      message = "Task completion cancelled"
    end

    # Calculate current progress
    assignments = current_user.task_assignments
    total = assignments.count
    done = assignments.select(&:done?).count
    all_completed = (done == total)

    respond_to do |format|
      format.html { redirect_to root_path(as: params[:as]), notice: message }
      format.json {
        render json: {
          success: true,
          message: message,
          done: done,
          total: total,
          all_completed: all_completed
        }
      }
    end
  end
end
