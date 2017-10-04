# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171002124342) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calculations", force: :cascade do |t|
    t.float "base_amount", null: false
    t.string "base_currency", limit: 3, null: false
    t.string "target_currency", limit: 3, null: false
    t.date "wait_until", null: false
    t.datetime "created_at"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.jsonb "rate_data", default: {}, null: false
    t.date "created_at", null: false
  end

end
