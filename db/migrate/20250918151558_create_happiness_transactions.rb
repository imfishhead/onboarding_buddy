class CreateHappinessTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :happiness_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :delta
      t.integer :balance_after
      t.string :source_type
      t.bigint :source_id
      t.string :reason
      t.jsonb :payload
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
