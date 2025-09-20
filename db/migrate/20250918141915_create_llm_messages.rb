class CreateLlmMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_messages do |t|
      t.references :llm_session, null: false, foreign_key: true
      t.integer :role
      t.text :content
      t.jsonb :meta

      t.timestamps
    end
  end
end
