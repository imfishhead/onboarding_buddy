class User < ApplicationRecord
  has_many :task_assignments, dependent: :destroy
end
