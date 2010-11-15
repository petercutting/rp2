class ModLatLonToChar < ActiveRecord::Migration
  def self.up
        change_column :igcpoints, :lat, :string, :limit => 10
        change_column :igcpoints, :lon, :string, :limit => 10
  end

  def self.down
        change_column :igcpoints, :lat, :string
        change_column :igcpoints, :lon, :string
  end
end