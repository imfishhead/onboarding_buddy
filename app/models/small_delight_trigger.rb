class SmallDelightTrigger < ApplicationRecord
  belongs_to :user
  enum :trigger_type, { task_done: 0, low_mood: 1, level_up: 2 }
end
