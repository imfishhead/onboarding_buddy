class HappinessTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :source, polymorphic: true, optional: true
end
