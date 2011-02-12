class AddColumnSchedules3 < ActiveRecord::Migration
  def self.up
    add_column :schedules, :user_id,:integer
  end

  def self.down
  end
end
