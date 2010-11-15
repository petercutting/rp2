class AddAlt < ActiveRecord::Migration
  def self.up
        add_column :igcpoints, :gps_alt, :integer
        add_column :igcpoints, :baro_alt, :integer
  end

  def self.down
        remove_column :igcpoints, :gps_alt
        remove_column :igcpoints, :baro_alt
  end
end

