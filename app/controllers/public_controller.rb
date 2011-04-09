class PublicController < ApplicationController

  #----------#
  # calendar #
  #----------#
  def calendar
    
    @mode = "public"
    
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
    @mode = "public"

    @now_date = Date.parse( params[:date] )

    #@schedules = Schedule.paginate( :page => params[:page], :per_page => $per_page, :order => "schedule_date DESC, id ASC" )

    # リストスケジュール取得
    @schedules = Schedule.get_list_schedule( :page => params[:page], :per_page => $per_page, :mode => @mode, :user_id => session[:user_id] )
  end

  #------#
  # show #
  #------#
  def show
    @mode = "public"

    @now_date = Date.parse( params[:date] )
    @schedule = Schedule.find( params[:id] ) unless params[:id].blank?
    @user = User.find_by_id( @schedule.user_id ) unless @schedule.blank?

    # アクセス権限チェック
    if !@schedule.blank? and ( @schedule.mode == "非公開" and session[:user_id] != @schedule.user_id )
      flash[:notice] = 'アクセス権限がありません。'
      redirect_to :root and return
    end
  end

end
