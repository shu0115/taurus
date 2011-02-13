class Schedule < ActiveRecord::Base

  #------------------------#
  # self.get_list_schedule #
  #------------------------#
  # リストスケジュール取得
  def self.get_list_schedule( args )

    page = args[:page]
    per_page = args[:per_page]
    mode = args[:mode]
    user_id = args[:user_id]

    condition_text = ""
    condition_hash = Hash.new
    month_schedules = Hash.new

    if mode == "public"
      condition_text += " mode = '公開' "
    else
      condition_text += " user_id = :user_id "
      condition_hash[:user_id] = user_id
    end

    schedules = Schedule.paginate(
      :page => page, 
      :per_page => per_page, 
      :conditions => [ condition_text, condition_hash ],
      :order => "schedule_date DESC, id ASC"
    )

    return schedules
  end

  #-------------------------#
  # self.get_month_schedule #
  #-------------------------#
  # 月内スケジュール取得
  def self.get_month_schedule( args )

    date = args[:date]
    mode = args[:mode]
    user_id = args[:user_id]

    condition_text = ""
    condition_hash = Hash.new
    month_schedules = Hash.new

    condition_text += ' schedule_date >= :start_date AND schedule_date <= :end_date '
    condition_hash[:start_date] = Date.new( date.year, date.month, 1 )
    condition_hash[:end_date] = Date.new( date.year, date.month, Time.days_in_month(date.month, date.year) )

    if mode == "public"
      condition_text += " AND mode = '公開' "
    else
      condition_text += " AND user_id = :user_id "
      condition_hash[:user_id] = user_id
    end

    schedules = Schedule.find(
      :all,
      :conditions => [ condition_text, condition_hash ]
    )

    # スケジュールマトリックス生成
    schedules.each_with_index{ | value, index |
      month_schedules[value.schedule_date.to_s] = Array.new if month_schedules[value.schedule_date.to_s].blank?
      month_schedules[value.schedule_date.to_s].push( value )
    }

    return month_schedules
  end

end
