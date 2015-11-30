class SessionsController < ApplicationController
  def welcome
    @message = "Hello World"
  end

  def create
    retrieved_information = auth_hash
    @user = User.find_or_create_from_auth_hash(retrieved_information)
    session[:user_id] = @user.id

    redirect_to users_path(screen_name: @user.screen_name)
  end

  # def destroy
  #   session.delete(:user_id)
  #   redirect_to root_path
  # end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end

end
