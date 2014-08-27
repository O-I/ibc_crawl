class TweetsController < ApplicationController
  def index
    @tweets = Tweet.search(params[:query]).order(sort).page(params[:page])
  end

  private

  def sort
    shuffle? ? 'RANDOM()' : "#{sort_column} #{sort_direction}"
  end

  def sort_column
    sortable_columns = %w(tweet_date favorite_count retweet_count)
    sortable_columns.include?(params[:col]) ? params[:col] : 'tweet_date'
  end

  def sort_direction
    %w(ASC DESC).include?(params[:dir]) ? params[:dir] : 'DESC'
  end

  def shuffle?
    params[:mix] == 'true'
  end
end