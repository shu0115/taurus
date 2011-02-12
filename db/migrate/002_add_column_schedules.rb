class AddColumnSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :start_time,:time
    add_column :schedules, :end_time,:time
  end

  def self.down
  end
end
