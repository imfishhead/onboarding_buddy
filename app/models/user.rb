class User < ApplicationRecord
  has_many :task_assignments, dependent: :destroy
  has_one :happiness_wallet, dependent: :destroy
  has_many :mood_checkins, dependent: :destroy
end
