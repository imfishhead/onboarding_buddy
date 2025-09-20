class LlmMessage < ApplicationRecord
  belongs_to :llm_session
  enum :role, { user: 0, assistant: 1, system: 2, tool: 3 }
  serialize :meta, coder: JSON
end
