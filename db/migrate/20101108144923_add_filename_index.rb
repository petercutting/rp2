class AddFilenameIndex < ActiveRecord::Migration
  def self.up
        add_index :igcfiles, :filename, :unique => true
  end

  def self.down
        remove_index :igcfiles, :filename
  end
end
