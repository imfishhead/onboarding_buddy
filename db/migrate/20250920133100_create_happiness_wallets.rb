class CreateHappinessWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :happiness_wallets do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :current_points
      t.integer :lifetime_points
      t.integer :level
      t.float :multiplier
      t.datetime :last_calculated_at

      t.timestamps
    end
  end
end
