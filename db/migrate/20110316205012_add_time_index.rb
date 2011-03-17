class AddTimeIndex < ActiveRecord::Migration
  def self.up
        add_index :pos, :time, :unique => true
  end

  def self.down
        remove_index :pos, :time
  end
end
