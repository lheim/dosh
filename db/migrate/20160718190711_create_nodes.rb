class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|

      t.string :nodename
      t.string :ip
      t.string :os
      t.string :cert

      t.timestamps null: false
    end
  end
end
