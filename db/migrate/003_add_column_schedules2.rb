class AddColumnSchedules2 < ActiveRecord::Migration
  def self.up
    add_column :schedules, :mode,:string
  end

  def self.down
  end
end
