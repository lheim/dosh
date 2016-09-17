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

ActiveRecord::Schema.define(version: 20160718190711) do

  create_table "nodes", force: :cascade do |t|
    t.string   "nodename"
    t.string   "ip"
    t.string   "containers"
    t.string   "cpu"
    t.string   "memory"
    t.string   "docker_version"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "usrps", force: :cascade do |t|
    t.string   "ip"
    t.string   "model"
    t.string   "assigned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
