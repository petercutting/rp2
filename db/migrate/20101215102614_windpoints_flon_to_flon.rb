class WindpointsFlonToFlon < ActiveRecord::Migration
  def self.up
        add_column :windpoints, :dlon, :float
        add_column :windpoints, :dlat, :float
        remove_column :windpoints, :flon
        remove_column :windpoints, :flat
  end

  def self.down
        add_column :windpoints, :flon, :float
        add_column :windpoints, :flat, :float
        remove_column :windpoints, :dlon
        remove_column :windpoints, :dlat
  end

end
