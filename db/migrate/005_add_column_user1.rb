class AddColumnUser1 < ActiveRecord::Migration
  def self.up
    add_column :users, :display_name, :string
  end

  def self.down
  end
end
