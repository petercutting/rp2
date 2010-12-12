class AddWindIndex < ActiveRecord::Migration
  def self.up
        add_index :windpoints, :igcfile_id
  end

  def self.down
        remove_index :windpoints, :igcfile_id
  end
end
