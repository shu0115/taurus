class Utility

  #----------------------#
  # self.replace_message #
  #----------------------#
  # メッセージ置換
  def self.replace_message( args )
    print "【 args[:message] 】>> " ; p args[:message] ;
    message = args[:message]
    message = message.gsub( "Member was successfully created.", "メンバーの作成が正常に完了しました。" )
    message = message.gsub( "Member was successfully updated.", "メンバーの更新が正常に完了しました。" )
    message = message.gsub( "User was successfully created.", "ユーザ登録が正常に完了しました。" )

    print "【 message 】>> " ; p message ;
    return message
  end

  #----------------------------#
  # self.error_replace_message #
  #----------------------------#
  # エラーメッセージ置換
  def self.error_replace_message( args )

    message = ""

    args[:errors].each{ |data| message += "#{data[1]}<br />" }

    return message
  end
  
  #-------------------#
  # self.fmt_holidays #
  #-------------------#
  def self.fmt_holidays( year )
  
    holidays = []
    #元日
    holidays << "01/01"
    #建国記念の日
    holidays << "02/11"
    #昭和の日
    holidays << "04/29"
    #憲法記念日
    holidays << "05/03"
    #みどりの日
    if year >= 2007
       holidays << "05/04"
    end
    #こどもの日
    holidays << "05/05"
    #文化の日
    holidays << "11/03"
    #勤労感謝の日
    holidays << "11/23"
    #天皇誕生日(平成)
    if year >= 1989
       holidays << "12/23"
    end
    #--------------------
    #春分の日
    d = 0
    if year < 1980
       d = (20.8357 + 0.242194 * (year - 1980) - ((year - 1983) / 4).to_i).to_i
    else
       d = (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) / 4).to_i).to_i
    end
    if d >= 1 && d <= 31
       holidays << "03/" + sprintf("%02d", d).to_s
    end
    #--------------------
    #秋分の日
    d = 0
    if year < 1980
       d = (23.2588 + 0.242194 * (year - 1980) - ((year - 1983) / 4).to_i).to_i
    else
       d = (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) / 4).to_i).to_i
    end
    if d >= 1 && d <= 30
       holidays << "09/" + sprintf("%02d", d).to_s
    end
    #--------------------
    #成人の日・体育の日 ～1999年
    if year < 2000
       holidays << "01/15"
       holidays << "10/10"
    else
       #成人の日[1月第2月曜日]
       for i in 8..14
           day = Date.strptime(year.to_s + "/01/" + i.to_s, "%Y/%m/%d")
           if day.wday == 1
              holidays << day.strftime("%m/%d")
              break
           end
       end
       #体育の日[10月第2月曜日]
       for i in 8..14
           day = Date.strptime(year.to_s + "/10/" + i.to_s, "%Y/%m/%d")
           if day.wday == 1
              holidays << day.strftime("%m/%d")
              break
           end
       end
    end
    #海の日
    if year >= 1996 && year < 2003
       holidays << "07/20"
    else
       #海の日[7月第3月曜日]
       if year >= 2003
          for i in 15..21
              day = Date.strptime(year.to_s + "/07/" + i.to_s, "%Y/%m/%d" )
              if day.wday == 1
                 holidays << day.strftime("%m/%d")
                 break
              end
          end
       end
    end
    #敬老の日
    if year < 2003
       holidays << "09/15"
    else
       #敬老の日[9月第3月曜日]
       if year >= 2003
          for i in 15..21
              day = Date.strptime(year.to_s + "/09/" + i.to_s, "%Y/%m/%d")
              if day.wday == 1
                 holidays << day.strftime("%m/%d")
                 break
              end
          end
       end
    end
    #--------------------
    holidays
  end

  #---------------#
  # self.holiday? #
  #---------------#
  def self.holiday?( date, holidays = [] )
  
    return false unless date
    return false unless holidays || holidays.size == 0
  
    year = date.strftime("%Y").to_i
    for h in holidays
        return true if date.strftime("%m/%d").to_s == h
    end
    return false
  end

  #------------------#
  # self.holiday_ja? #
  #------------------#  
  def self.holiday_ja?( d )
  
    return false unless d
    date = d.kind_of?(String) ? Date.new(d[0..3].to_i, d[5..6].to_i, d[8..9].to_i) : d
  
    year = date.strftime("%Y").to_i
    holidays = fmt_holidays(year)
  
    # 通常の祝日だったらtrueで処理終わり
    return true if holiday?(date, holidays)
  
    # 日曜日だったらfalseで処理終わり
    return false if date.wday == 0
  
    # 振替休日（5月6日対策でこうなりました。）
    sw_furikae = 0
    1.upto(366) do |j|
       sw_furikae = 0
  
       if holiday?(date - j.days, holidays)
          sw_furikae = 1
          #祝日が日曜日ならtrue, 処理終わり
          return true if (date - j.days).wday == 0
       end
  
       break if sw_furikae == 0
    end
  
    #月曜日だったらfalseで処理終わり
    return false if date.wday == 1
  
    #国民の休日[祝日と祝日ではさまれた日。振替休日と重なる場合は振替休日優先∴火～土曜日]
    return true if holiday?(date - 1.day, holidays) && holiday?(date + 1.day, holidays)
  
    return false
  end

end
