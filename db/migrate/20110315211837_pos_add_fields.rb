class PosAddFields < ActiveRecord::Migration
  def self.up
        add_column :pos, :latitude, :float
        add_column :pos, :longitude, :float
        add_column :pos, :accuracy, :float
        add_column :pos, :altitude, :float
        add_column :pos, :time, :datetime
        add_column :pos, :bearing, :float
        add_column :pos, :speed, :float
        add_column :pos, :provider, :string
        add_column :pos, :battlevel, :integer
  end

  def self.down
        remove_column :pos, :latitude
        remove_column :pos, :longitude
        remove_column :pos, :accuracy
        remove_column :pos, :altitude
        remove_column :pos, :time
        remove_column :pos, :bearing
        remove_column :pos, :speed
        remove_column :pos, :provider
        remove_column :pos, :battlevel

  end
end
