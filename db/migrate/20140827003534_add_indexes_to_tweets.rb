class AddIndexesToTweets < ActiveRecord::Migration
  def change
    add_index :tweets, :tweet_id, unique: true
    add_index :tweets, :tweet_date
    add_index :tweets, :tweeter_name
    add_index :tweets, :tweeter_screen_name
    add_index :tweets, :retweet_count
    add_index :tweets, :favorite_count
  end
end
