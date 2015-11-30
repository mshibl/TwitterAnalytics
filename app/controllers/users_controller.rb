class UsersController < ApplicationController
    def index
    # Ajax request for the twitter stream
      @screen_name = params[:screen_name]
      @welcome = "Hello #{@screen_name}"
      @user = User.find_by(screen_name: @screen_name)

      # if request.xhr?
      #   timestamp = params[:timestamp].to_f
      #   tweets_to_display =  UsersHelper.get_matching_tweets(@user, timestamp)
      #   render :json => tweets_to_display
      # else

      # # User information to be displayed
      # user_information = get_user_info(@screen_name)
      # @profile_picture = user_information[:profile_picture]
      # @num_tweets = user_information[:num_tweets]
      # @num_following = user_information[:num_following]
      # if History.find_by(user_id: user_information[:user_id])
      #   @followers_count = History.where(user_id: user_information[:user_id]).last.followers_count
      # end

      # # Getting the graph data
      # graph_data = UsersHelper.get_chart(@user)
      # @xData = graph_data[0]
      # @followers_record = graph_data[1]
      # @favorites = graph_data[2]
      # @data_changes = graph_data[3]
    # end
  end

  # def edit
  #   @user = User.find(session[:user_id])
  # end

  def signup
    @user = User.find(session[:user_id])
  end
end
