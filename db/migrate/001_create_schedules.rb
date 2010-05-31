class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :title
      t.date :schedule_date
      t.integer :cycle
      t.string :cycle_mode
      t.text :note

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
