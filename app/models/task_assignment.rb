class TaskAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :onboarding_task
  enum :status, { pending: 0, done: 1, blocked: 2 }, default: :pending
end
