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

ActiveRecord::Schema[7.1].define(version: 2025_11_30_153340) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label", default: "Home", null: false
    t.string "full_name", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "city", null: false
    t.string "county"
    t.string "postcode", null: false
    t.string "country", default: "United Kingdom", null: false
    t.string "phone"
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["postcode"], name: "index_addresses_on_postcode"
    t.index ["user_id", "primary"], name: "index_addresses_on_user_id_and_primary"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login", default: false, null: false
    t.text "otp_backup_codes"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.bigint "stock_id"
    t.string "size"
    t.integer "quantity", null: false
    t.integer "price", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id", "size"], name: "index_cart_items_on_cart_id_and_product_id_and_size", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["stock_id"], name: "index_cart_items_on_stock_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "session_token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["expires_at"], name: "index_carts_on_expires_at"
    t.index ["session_token"], name: "index_carts_on_session_token", unique: true
    t.index ["user_id", "expires_at"], name: "index_carts_on_user_id_and_expires_at"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_products", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "order_id", null: false
    t.string "size"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
    t.index ["order_id"], name: "index_order_products_on_order_id"
    t.index ["product_id"], name: "index_order_products_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "customer_email"
    t.boolean "fulfilled"
    t.integer "total"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone"
    t.string "billing_name"
    t.string "billing_address"
    t.string "payment_status"
    t.string "payment_id"
    t.integer "shipping_cost"
    t.string "shipping_id"
    t.string "shipping_description"
    t.bigint "user_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["fulfilled", "created_at"], name: "index_orders_on_fulfilled_and_created_at"
    t.index ["fulfilled"], name: "index_orders_on_fulfilled"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "price"
    t.integer "category_id", null: false
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "stock_level"
    t.integer "shipping_weight"
    t.integer "shipping_length"
    t.integer "shipping_width"
    t.integer "shipping_height"
    t.boolean "fiberglass_reinforcement", default: false, null: false
    t.integer "min_resin_per_m2", default: 0, null: false
    t.integer "max_resin_per_m2", default: 0, null: false
    t.integer "avg_resin_per_m2", default: 0, null: false
    t.index ["active", "price", "category_id"], name: "index_products_on_active_and_price_and_category_id"
    t.index ["active"], name: "index_products_on_active"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["name"], name: "index_products_on_name"
    t.index ["price"], name: "index_products_on_price"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "size"
    t.integer "stock_level"
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price"
    t.integer "shipping_weight"
    t.integer "shipping_length"
    t.integer "shipping_width"
    t.integer "shipping_height"
    t.boolean "fiberglass_reinforcement", default: false, null: false
    t.integer "min_resin_per_m2", default: 0, null: false
    t.integer "max_resin_per_m2", default: 0, null: false
    t.integer "avg_resin_per_m2", default: 0, null: false
    t.index ["product_id"], name: "index_stocks_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "full_name", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["full_name"], name: "index_users_on_full_name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["event"], name: "index_versions_on_event"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users", on_delete: :cascade
  add_foreign_key "cart_items", "carts", on_update: :cascade, on_delete: :cascade
  add_foreign_key "cart_items", "products", on_update: :cascade, on_delete: :cascade
  add_foreign_key "cart_items", "stocks", on_update: :cascade, on_delete: :cascade
  add_foreign_key "carts", "users", on_delete: :nullify
  add_foreign_key "order_products", "orders"
  add_foreign_key "order_products", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "stocks", "products"
end
