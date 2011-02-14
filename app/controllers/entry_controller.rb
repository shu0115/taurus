class EntryController < ApplicationController

  #-------#
  # input #
  #-------#
  def input
    @user = User.new( params[:user] )
  end

  #--------------#
  # confirmation #
  #--------------#
  def confirmation
    @user = User.new( params[:user] )
    password_clear

    unless @user.valid?
      render :action => 'input', :user => params[:user]
      return
    end
  end

  #----------#
  # complete #
  #----------#
  def complete
    @user = User.new( params[:user] )

    if @user.save
      # ユーザID／ログインIDをセッションに格納
      session[:user_id] = @user.id
      session[:login_id] = @user.login_id
      session[:display_name] = @user.display_name

      flash[:notice] = 'ユーザ登録が完了しました。'
      redirect_to :root
      return
    else
      password_clear
      render :action => "input", :user => params[:user]
      return
    end
  end

  #-------#
  # login #
  #-------#
  def login
    @user = User.new( params[:login] )

    return if @user.blank?

    if !@user.login_id.blank? and !@user.password.blank?
      # ユーザ認証
      user = @user.authenticate

      unless user.blank?
        # ユーザID／ログインIDをセッションに格納
        session[:user_id] = user.id
        session[:login_id] = user.login_id
        session[:display_name] = user.display_name

        flash[:notice] = "ログインに成功しました。"
        redirect_to params[:request_url]
        return
      else
        flash[:notice] = "ログインIDもしくはパスワードが正しくありません。"
        redirect_to params[:request_url]
        return
      end
    end
  end

  #--------#
  # logout #
  #--------#
  def logout
    session[:user_id] = nil

    flash[:notice] = "ログアウトしました。"
    redirect_to params[:request_url]
    return
  end

  #------#
  # show #
  #------#
  def show
    @user = User.find_by_id( session[:user_id] )
  end

  #------#
  # edit #
  #------#
  def edit
    @user = User.find_by_id( session[:user_id] )
  end

  #--------#
  # update #
  #--------#
  def update
    @user = User.find_by_id( session[:user_id] )

    if params[:user].blank?
      flash[:notice] = '登録情報がありません。'
      password_clear
      redirect_to :action => "edit", :user => params[:user]
      return
    end

    # パスワードチェックがtrueで無ければ
    unless @user.password_check?( params[:user][:password] )
      flash[:notice] = '「現在のパスワード」が正しくありません。'
      password_clear
      redirect_to :action => "edit", :user => params[:user]
      return
    end

    if !params[:user][:edit_password].blank? or !params[:user][:edit_password_confirmation].blank?
      # 変更するパスワードと再入力パスワードが一致しなければ
      unless params[:user][:edit_password] == params[:user][:edit_password_confirmation]
        flash[:notice] = '「変更するパスワード」と「変更するパスワード(再入力)」が一致しません。'
        password_clear
        redirect_to :action => "edit", :user => params[:user]
        return
      else
        # パスワード更新
        params[:user][:password] = params[:user][:edit_password]
      end
#    else
#      flash[:notice] = '「変更するパスワード」と「変更するパスワード(再入力)」を入力して下さい。'
#      password_clear
#      redirect_to :action => "edit", :user => params[:user]
#      return
    end

    # バリデーションチェック
    unless User.login_id_duplicate?( params[:user][:login_id], session[:user_id] )
      flash[:notice] = '指定された ログインID は既に登録されています。'
      password_clear
      redirect_to :action => "edit", :user => params[:user]
      return
    end

    # ユーザ情報を更新
    if @user.update_attributes( params[:user] )
      session[:login_id] = @user.login_id
      session[:display_name] = @user.display_name
      flash[:notice] = '登録情報を更新しました。'
      redirect_to :action => "show"
      return
    else
      flash[:notice] = '登録情報の更新に失敗しました。'
      password_clear
      redirect_to :action => "edit", :user => params[:user]
      return
    end
  end

  private
  #----------------#
  # password_clear #
  #----------------#
  def password_clear
    unless params[:user].blank?
      params[:user][:password] = nil
      params[:user][:password_confirmation] = nil
    end
  end

end
