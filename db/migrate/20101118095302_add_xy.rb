class AddXy < ActiveRecord::Migration
  def self.up
        add_column :igcpoints, :x, :integer
        add_column :igcpoints, :y, :integer
  end

  def self.down
        remove_column :igcpoints, :x
        remove_column :igcpoints, :y
  end
end
