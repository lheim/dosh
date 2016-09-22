class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|

      t.string :nodename
      t.string :ip
      t.string :containers
      t.string :cpu
      t.string :memory
      t.string :docker_version

      t.timestamps null: false
    end
  end
end
