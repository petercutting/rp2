class AddWindpointsDlon2 < ActiveRecord::Migration
  def self.up
        add_column :windpoints, :dlon2, :float
        add_column :windpoints, :dlat2, :float

  end

  def self.down

        remove_column :windpoints, :dlon2
        remove_column :windpoints, :dlat2
  end
end
