class AddSeq < ActiveRecord::Migration
  def self.up
        add_column :igcpoints, :seq_secs, :integer
  end

  def self.down
        remove_column :igcpoints, :seq_secs
  end
end
