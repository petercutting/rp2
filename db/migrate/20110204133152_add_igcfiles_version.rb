class AddIgcfilesVersion < ActiveRecord::Migration
  def self.up
        add_column :igcfiles, :proc_version, :integer
  end

  def self.down
        remove_column :igcfiles, :proc_version
  end
end
