ENV["RACK_ENV"] ||= "development"
require 'sinatra/base'
require 'sinatra/flash'
require_relative 'data_mapper_setup'

# :nodoc:
class Fitter < Sinatra::Base
  use Rack::MethodOverride
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
      flash.now[:errors] = user.errors.full_messages
      erb :'users/new', :layout => :'users/layout'
    end
  end

  get '/posts/new' do
    erb :'posts/new'
  end

  post '/posts' do
    post = Post.create(tip: params[:tip], user_id: current_user.id, user_name: current_user.user_name)
    current_user.posts << post
    post.save
    current_user.save
    redirect '/posts'
  end

  get '/posts' do
    @posts = Post.all
    @user = current_user
    erb :'posts/index', :layout => :'posts/layout'
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/posts'
    else
      flash.now[:errors] = ['The email or password is incorrect']
      erb :'sessions/new', :layout => :'sessions/layout'
    end
  end

  delete '/sessions' do
    session[:user_id] = nil
    flash.keep[:notice] = 'Goodbye, and stay healthy!'
    redirect to '/posts'
  end

  run! if app_file == $PROGRAM_NAME
end
