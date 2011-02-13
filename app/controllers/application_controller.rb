# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  require 'date'

  layout 'base'

  # 曜日
  $wdays = [ "日", "月", "火", "水", "木", "金", "土" ]

  # 周期
  $cycle_mode = [ "day", "month", "year" ]

  # 公開設定
  $mode = [ '公開', '非公開' ]

  # ページ内件数
  $per_page = 5

end
