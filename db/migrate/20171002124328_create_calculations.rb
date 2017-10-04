class CreateCalculations < ActiveRecord::Migration[5.1]
  def change
    create_table :calculations do |t|

      t.float   :base_amount, null: false

      t.string :base_currency, null: false, limit: 3
      t.string :target_currency, null: false, limit: 3

      t.date    :wait_until, null: false
      t.datetime :created_at
    end
  end
end
