class LlmSession < ApplicationRecord
  belongs_to :user
  has_many :llm_messages, dependent: :destroy

  enum :channel, { app: 0, web: 1 }, default: :app
  enum :purpose, { faq: 0, emotion_support: 1, translation: 2 }, default: :faq
end
