class OnboardingTask < ApplicationRecord
  has_many :task_assignments, dependent: :destroy
  validates :title, presence: true
  default_scope { order(:order_num, :id) }
end
