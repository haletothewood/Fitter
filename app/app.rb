ENV["RACK_ENV"] ||= "development"
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'

# :nodoc:
class Fitter < Sinatra::Base
  register Sinatra::Flash

  enable :sessions
  set :session_secret, 'super secret'

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/' do
    redirect '/posts'
  end

  get '/users/new' do
    erb :'users/new'
  end

  post '/users' do
    user = User.create(name: params[:name],
                user_name: params[:user_name],
                email: params[:email],
                password: params[:password],
                password_confirmation: params[:password_confirmation])
    if user.save
      session[:user_id] = user.id
      redirect '/posts'
    else
      flash.now[:notice] = 'Your passwords don\'t match!'
      erb :'users/new', :layout => :'users/layout'
    end
  end

  get '/posts/new' do
    erb :'posts/new'
  end

  post '/posts' do
    post = Post.create(tip: params[:tip])
    post.save
    redirect '/posts'
  end

  get '/posts' do
    @posts = Post.all
    @user = session[:user_id]
    erb :'posts/index', :layout => :'posts/layout'
  end

  run! if app_file == $PROGRAM_NAME
end
