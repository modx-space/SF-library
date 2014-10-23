# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140814091046) do

  create_table "books", force: true do |t|
    t.string   "name"
    t.string   "picture"
    t.text     "intro"
    t.string   "author"
    t.string   "isbn"
    t.string   "press"
    t.date     "publish_date"
    t.string   "language"
    t.string   "category"
    t.float    "price"
    t.integer  "total"
    t.integer  "store"
    t.integer  "point"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "store_date"
  end

  create_table "borrows", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.datetime "should_return_date"
    t.string   "status"
    t.integer  "is_expired"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "team"
    t.string   "role"
    t.string   "password_digest"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.string   "book_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
