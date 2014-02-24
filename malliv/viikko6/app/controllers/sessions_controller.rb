class SessionsController < ApplicationController
  def new
    # renderöi kirjautumissivun
  end

  def create
    user = User.find_by username: params[:username]

    if user.nil? or not user.authenticate params[:password]
      redirect_to :back, notice: "username and password do not match"
    else
      session[:user_id] = user.id
      redirect_to user_path(user), notice: "Welcome back!"
    end
  end

  def create_fb
    name = env['omniauth.auth']['info']['name']
    user = User.find_by(username:name)

    if user.nil?
      user = User.create! username:name, password:'Arandomstr1nghere', password_confirmation:'Arandomstr1nghere'
    end

    session[:user_id] = user.id
    redirect_to user_path(user), notice: "Welcome back!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to :root
  end
end