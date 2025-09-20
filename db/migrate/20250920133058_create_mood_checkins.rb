class CreateMoodCheckins < ActiveRecord::Migration[8.0]
  def change
    create_table :mood_checkins do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :score
      t.text :note

      t.timestamps
    end
  end
end
