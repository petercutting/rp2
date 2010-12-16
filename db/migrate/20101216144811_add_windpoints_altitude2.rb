class AddWindpointsAltitude2 < ActiveRecord::Migration
  def self.up
        add_column :windpoints, :altitude2, :integer
        add_column :windpoints, :seq_secs2, :integer

  end

  def self.down

        remove_column :windpoints, :altitude2
        remove_column :windpoints, :seq_secs2
  end
end
