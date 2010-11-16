class CombineLatLon < ActiveRecord::Migration
  def self.up
    remove_column :igcpoints, :lat
    remove_column :igcpoints, :lon
    add_column :igcpoints, :lat_lon, :string, :limit => 20
  end

  def self.down
    add_column :igcpoints, :lat, :string, :limit => 10
    add_column :igcpoints, :lon, :string, :limit => 10
    remove_column :igcpoints, :lat_lon
  end
end
