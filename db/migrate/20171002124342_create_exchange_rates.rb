class CreateExchangeRates < ActiveRecord::Migration[5.1]
  def change
    create_table :exchange_rates do |t|
      t.jsonb  :rate_data, null: false, default: {}

      # We are not using t.timestamps here as we need only
      # created_at here and it should be date
      t.date :created_at, null: false, unique: true
    end
  end
end
