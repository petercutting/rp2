class AddDecLatLon < ActiveRecord::Migration
  def self.up
        add_column :igcpoints, :flat, :float
        add_column :igcpoints, :flon, :float
  end

  def self.down
        remove_column :igcpoints, :flat
        remove_column :igcpoints, :flon
  end
end
