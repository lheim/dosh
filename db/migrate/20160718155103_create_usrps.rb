class CreateUsrps < ActiveRecord::Migration
  def change
    create_table :usrps do |t|

      t.string :ip
      t.string :model
      t.string :assigned
      t.string :status

      t.timestamps null: false
    end
  end
end
