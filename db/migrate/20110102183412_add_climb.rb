class AddClimb < ActiveRecord::Migration
  def self.up
        add_column :windpoints, :climb, :float
  end

  def self.down
        remove_column :windpoints, :climb
  end
end
