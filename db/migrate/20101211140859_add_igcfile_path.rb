class AddIgcfilePath < ActiveRecord::Migration
  def self.up
        add_column :igcfiles, :path, :string
  end

  def self.down
        remove_column :igcfiles, :path
  end
end
