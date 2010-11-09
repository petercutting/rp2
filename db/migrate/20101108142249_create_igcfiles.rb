# http://www.dizzy.co.uk/ruby_on_rails/cheatsheets/rails-migrations

class CreateIgcfiles < ActiveRecord::Migration
  def self.up
    create_table :igcfiles do |t|
      t.string :filename
      t.integer :wind_direction
      t.integer :wind_strength

      t.timestamps
    end
  end

  def self.down
    drop_table :igcfiles
  end
end
