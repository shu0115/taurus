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
      flash[:notice] = 'User was successfully created.'
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
    @user = User.new( params[:user] )

    return if @user.blank?

    if !@user.login_id.blank? and !@user.password.blank?
      # ユーザ認証
      user = @user.authenticate

      unless user.blank?
        # ユーザIDをセッションに格納
        session[:user_id] = user.id

        flash[:notice] = "ログインに成功しました。"
        redirect_to :root
        return
      else
        flash[:notice] = "ログインIDもしくはパスワードが正しくありません。"
      end
    end
  end

  #--------#
  # logout #
  #--------#
  def logout
    session[:user_id] = nil

    flash[:notice] = "ログアウトしました。"
    redirect_to :controller => "top"
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
      flash[:notice] = 'ユーザ情報がありません。'
      redirect_to :action => "edit"
      return
    end

    # パスワードチェックがtrueで無ければ
    unless @user.password_check?( params[:user][:password] )
      flash[:notice] = '「現在のパスワード」が正しくありません。'
      redirect_to :action => "edit"
      return
    end

    if !params[:user][:edit_password].blank? and !params[:user][:edit_password_confirmation].blank?
      # 変更するパスワードと再入力パスワードが一致しなければ
      unless params[:user][:edit_password] == params[:user][:edit_password_confirmation]
        flash[:notice] = '「変更するパスワード」と「変更するパスワード(再入力)」が一致しません。'
        redirect_to :action => "edit"
        return
      else
        # パスワード更新
        params[:user][:password] = params[:user][:edit_password]
      end
    end

    # ユーザ情報を更新
    if @user.update_attributes( params[:user] )
      flash[:notice] = 'ユーザ情報を更新しました。'
      redirect_to :action => "show"
      return
    else
      flash[:notice] = 'ユーザ情報の更新に失敗しました。'
      redirect_to :action => "edit"
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
