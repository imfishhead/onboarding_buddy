class User < ApplicationRecord
  has_many :task_assignments, dependent: :destroy
  has_many :llm_sessions, dependent: :destroy
  has_many :mood_checkins, dependent: :destroy
  has_many :small_delight_triggers, dependent: :destroy
  has_many :happiness_transactions, dependent: :destroy
  has_one :happiness_wallet, dependent: :destroy
end
