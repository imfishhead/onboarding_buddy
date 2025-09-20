class CreateSmallDelightTriggers < ActiveRecord::Migration[8.0]
  def change
    create_table :small_delight_triggers do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :trigger_type
      t.text :payload

      t.timestamps
    end
  end
end
