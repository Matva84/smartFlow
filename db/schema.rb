# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_12_060510) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "rib"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
  end

  create_table "employees", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "group"
    t.string "position"
    t.float "hoursalary"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "default_days_off", default: [6, 0], array: true
    t.float "total_leaves_taken", default: 0.0
    t.boolean "admin", default: false, null: false
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "employees_projects", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "employee_id", null: false
  end

  create_table "events", force: :cascade do |t|
    t.string "event_type"
    t.date "start_date"
    t.date "end_date"
    t.bigint "employee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "part_of_day"
    t.float "leave_days_count", default: 0.0
    t.string "status", default: "en_attente"
    t.decimal "overtime_hours"
    t.index ["employee_id"], name: "index_events_on_employee_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.decimal "amount"
    t.date "date"
    t.text "description"
    t.string "status"
    t.string "image"
    t.boolean "fixed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "category", default: "Non classée"
    t.index ["employee_id"], name: "index_expenses_on_employee_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "category"
    t.text "description"
    t.integer "duration"
    t.integer "nb_people"
    t.decimal "hourly_cost"
    t.decimal "human_margin"
    t.decimal "human_total_cost"
    t.string "material"
    t.decimal "unit_price_ht"
    t.integer "quantity"
    t.decimal "total_price_ht"
    t.decimal "material_margin"
    t.decimal "vat_value"
    t.decimal "material_cost"
    t.decimal "total_cumulative"
    t.decimal "total_margin"
    t.bigint "quote_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quote_id"], name: "index_items_on_quote_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "name"
    t.decimal "unit_price"
    t.decimal "margin"
    t.integer "quantity"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_materials_on_item_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.bigint "user_id", null: false
    t.bigint "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "messageable_type"
    t.bigint "messageable_id"
    t.string "full_name"
    t.datetime "read_at"
    t.integer "recipient_id"
    t.index ["employee_id"], name: "index_messages_on_employee_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.date "start_at"
    t.date "end_at"
    t.date "initial_start_at"
    t.date "initial_end_at"
    t.float "totalbudget"
    t.integer "progression"
    t.float "human_cost"
    t.float "material_cost"
    t.float "customer_budget"
    t.float "total_expenses"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "number"
    t.string "status", default: "creation"
    t.decimal "total"
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_quote_id"
    t.index ["parent_quote_id"], name: "index_quotes_on_parent_quote_id"
    t.index ["project_id"], name: "index_quotes_on_project_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label"
    t.string "value_type", default: "string", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "employees", "users"
  add_foreign_key "events", "employees"
  add_foreign_key "expenses", "employees"
  add_foreign_key "items", "quotes"
  add_foreign_key "materials", "items"
  add_foreign_key "messages", "employees"
  add_foreign_key "messages", "users"
  add_foreign_key "projects", "clients"
  add_foreign_key "quotes", "projects"
end
