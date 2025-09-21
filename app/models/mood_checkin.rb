class MoodCheckin < ApplicationRecord
  belongs_to :user
  validates :score, inclusion: { in: -1..3 }
end
