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

ActiveRecord::Schema.define(version: 20150129072830) do

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
    t.string   "status"
    t.string   "tag"
  end

  create_table "borrows", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.datetime "should_return_date"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "return_at"
    t.integer  "deliver_handler_id"
    t.integer  "return_handler_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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
    t.string   "status"
    t.string   "building"
    t.string   "office"
    t.integer  "seat"
    t.string   "sf_email"
    t.string   "i_number"
  end

  create_table "votes", force: true do |t|
    t.integer  "user_id"
    t.string   "book_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
