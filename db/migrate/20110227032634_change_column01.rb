class ChangeColumn01 < ActiveRecord::Migration
  def self.up
    change_column :schedules, :start_time, :timestamp
    change_column :schedules, :end_time, :timestamp
  end

  def self.down
  end
end
