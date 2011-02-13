class SchedulesController < ApplicationController

  #----------#
  # calendar #
  #----------#
  def calendar
    
    if params[:mode].to_s == "public" or session[:user_id].blank?
      @mode = "public"
    end
    
    # paramsに年月日データが入っているなら、そのデータ[@date]に入れる。
    # 入っていなければ、今日の年月日データを[@date]入れる。
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
      @calendar_matrix.push( { :days => "　", :week_day => index } )
    }

    # 月内スケジュール取得
    @month_schedules = Schedule.get_month_schedule( :date => @now_date, :mode => @mode, :user_id => session[:user_id] )
  end

  #------#
  # list #
  #------#
  def list
    if params[:mode].to_s == "public" or session[:user_id].blank?
      @mode = "public"
    end

    @now_date = Date.parse( params[:date] )

    #@schedules = Schedule.paginate( :page => params[:page], :per_page => $per_page, :order => "schedule_date DESC, id ASC" )

    # リストスケジュール取得
    @schedules = Schedule.get_list_schedule( :page => params[:page], :per_page => $per_page, :mode => @mode, :user_id => session[:user_id] )
  end

  #------#
  # show #
  #------#
  def show
    if params[:mode].to_s == "public" or session[:user_id].blank?
      @mode = "public"
    end

    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
    @user = User.find_by_id( @schedule.user_id ) unless @schedule.blank?

    # アクセス権限チェック
    if !@schedule.blank? and ( @schedule.mode == "非公開" and session[:user_id] != @schedule.user_id )
      flash[:notice] = 'アクセス権限がありません。'
      redirect_to :root
      return
    end
  end

  #-----#
  # new #
  #-----#
  def new
    @now_date = Date.parse( params[:date] )
    if !params[:schedule_date_year].blank? and !params[:schedule_date_month].blank? and !params[:schedule_date_day].blank?
      schedule_date = Date.new( params[:schedule_date_year].to_i, params[:schedule_date_month].to_i, params[:schedule_date_day].to_i )
    end
    @schedule = Schedule.new( :schedule_date => schedule_date )
    @schedule.start_time = Time.parse("00:00")
    @schedule.end_time = Time.parse("00:00")
    @schedule.mode = '非公開'
  end

  #------#
  # edit #
  #------#
  def edit
    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
    @schedule.start_time = Time.parse("00:00") if @schedule.start_time.blank?
    @schedule.end_time = Time.parse("00:00") if @schedule.end_time.blank?

    # アクセス権限チェック
    if !@schedule.blank? and ( @schedule.mode == "非公開" and session[:user_id] != @schedule.user_id )
      flash[:notice] = 'アクセス権限がありません。'
      redirect_to :root
      return
    end
  end

  #--------#
  # create #
  #--------#
  def create
    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.new( params[:schedule] )

    if @schedule.save
      flash[:notice] = 'スケジュールを新規作成しました。'
      redirect_to :action => "calendar", :date => @now_date
    else
      flash[:notice] = 'スケジュールの新規作成に失敗しました。'
      render :action => "new", :date => @now_date
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?

print "【 Date.valid_date? 】>> " ; p Date.valid_date?( params[:schedule]["schedule_date(1i)"].to_i, params[:schedule]["schedule_date(2i)"].to_i, params[:schedule]["schedule_date(3i)"].to_i ) ;

    flash[:notice] = ""
    flash[:notice] += '日付が存在しません。<br />' if params[:schedule].blank? or !(Date.valid_date?( params[:schedule]["schedule_date(1i)"].to_i, params[:schedule]["schedule_date(2i)"].to_i, params[:schedule]["schedule_date(3i)"].to_i ))
    flash[:notice] += 'スケジュールデータが存在しません。<br />' if @schedule.blank?

    unless flash[:notice].blank?
      unless @schedule.blank?
        render :action => "edit", :id => @schedule.id, :date => @now_date
      else
        render :action => "edit", :date => @now_date
      end
      return
    end

    if @schedule.update_attributes( params[:schedule] )
      flash[:notice] = 'スケジュールの更新が完了しました。'
      redirect_to :action => "show", :id => @schedule.id, :date => @now_date
    else
      flash[:notice] = 'スケジュールの更新に失敗しました。'
      render :action => "edit", :id => @schedule.id, :date => @now_date
    end
  end

  #---------#
  # destroy #
  #---------#
  def destroy
    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
    @schedule.destroy unless @schedule.blank?

    redirect_to :action => params[:next], :date => @now_date
  end

end
