class CreateLlmSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :channel
      t.integer :purpose
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
