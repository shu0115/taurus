class Schedule < ActiveRecord::Base

  #-------------------------#
  # self.get_month_schedule #
  #-------------------------#
  def self.get_month_schedule( date )

    month_schedules = Hash.new

    schedules = Schedule.find( :all,
      :conditions => [
        "schedule_date >= :start_date AND schedule_date <= :end_date",
        { :start_date => Date.new( date.year, date.month, 1 ), :end_date => Date.new( date.year, date.month, Time.days_in_month(date.month, date.year) ) }
      ]
    )

    schedules.each_with_index{ | value, index |
      month_schedules[value.schedule_date.to_s] = Array.new if month_schedules[value.schedule_date.to_s].blank?
      month_schedules[value.schedule_date.to_s].push( value )
    }

    return month_schedules
  end

end
