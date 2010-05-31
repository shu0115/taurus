class SchedulesController < ApplicationController

  require 'date'
  require 'date/holiday'

  layout "base"

  $wdays = [ "日", "月", "火", "水", "木", "金", "土" ]
  $cycle_mode = [ "day", "month", "year" ]

  #----------#
  # calendar #
  #----------#
  def calendar

    p Date.new(2007,9,24).national_holiday?;

    #paramsに年月日データが入っているなら、そのデータ[@date]に入れる。
    #入っていなければ、今日の年月日データを[@date]入れる。
    if params[:date]
      begin
        @now_date = Date.parse( params[:date] )
      rescue
        @now_date = Date.today
      end
    else
      @now_date = Date.today
    end

    @calendar_matrix = Array.new

    # 月始め空欄埋め
    @now_date.beginning_of_month.wday.times{ | index |
      @calendar_matrix.push( { :days => "　", :week_day => index } )
    }

    # カレンダー日付セット
    Time.days_in_month( @now_date.month, @now_date.year ).times { | index |
      @calendar_matrix.push( { :days => (index + 1), :week_day => Date.new( @now_date.year, @now_date.month, (index + 1) ).wday } )
    }

    # 月終わり空欄埋め
    ( Date.new( @now_date.year, @now_date.month, ( Time.days_in_month( @now_date.month, @now_date.year ) ) ).wday + 1 ).upto( 6 ) { | index |
      puts index
      @calendar_matrix.push( { :days => "　", :week_day => index } )
    }


    # 月内スケジュール取得
    @month_schedules = Schedule.get_month_schedule( @now_date )

  end

  #------#
  # list #
  #------#
  def list
    @schedules = Schedule.find( :all, :order => "schedule_date DESC, id ASC" )
  end

  #------#
  # show #
  #------#
  def show
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
  end

  #-----#
  # new #
  #-----#
  def new
    if !params[:schedule_date_year].blank? and !params[:schedule_date_month].blank? and !params[:schedule_date_day].blank?
      schedule_date = Date.new( params[:schedule_date_year].to_i, params[:schedule_date_month].to_i, params[:schedule_date_day].to_i )
    end
    @schedule = Schedule.new( :schedule_date => schedule_date )
  end

  #------#
  # edit #
  #------#
  def edit
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
  end

  #--------#
  # create #
  #--------#
  def create
    @schedule = Schedule.new( params[:schedule] )

    if @schedule.save
      flash[:notice] = 'スケジュールを新規作成しました。'
      redirect_to "/schedules/list"
    else
      flash[:notice] = 'スケジュールの新規作成に失敗しました。'
      render :action => "new"
    end
  end

  #--------#
  # update #
  #--------#
  def update

    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?

    flash[:notice] = ""
    flash[:notice] += '日付が存在しません。<br />' if params[:schedule].blank? or !(Date::exist?( params[:schedule]["schedule_date(1i)"].to_i, params[:schedule]["schedule_date(2i)"].to_i, params[:schedule]["schedule_date(3i)"].to_i ))
    flash[:notice] += 'スケジュールデータが存在しません。<br />' if @schedule.blank?

    unless flash[:notice].blank?
      unless @schedule.blank?
        render :action => "edit", :id => @schedule.id
      else
        render :action => "edit"
      end
      return
    end

#    begin
    if @schedule.update_attributes( params[:schedule] )
      flash[:notice] = 'スケジュールの更新が完了しました。'
      redirect_to "/schedules/show/#{@schedule.id}"
    else
      flash[:notice] = 'スケジュールの更新に失敗しました。'
      render :action => "edit", :id => @schedule.id
    end
#    rescue => exc
#      print "【 exc 】 >> " ; p exc
#      render :action => "edit", :id => @schedule.id
#    end

  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
    @schedule.destroy unless @schedule.blank?

    redirect_to "/schedules/list"
  end

end