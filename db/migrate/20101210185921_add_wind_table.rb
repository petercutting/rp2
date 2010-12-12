class AddWindTable < ActiveRecord::Migration
  def self.up
    create_table :windpoints do |t|
      t.integer :igcfile_id
      t.float :flat
      t.float :flon
      t.float :direction
      t.integer :speed
      t.integer :altitude
      t.integer :seq_secs
    end
  end

  def self.down
    drop_table :windpoints
  end
end
