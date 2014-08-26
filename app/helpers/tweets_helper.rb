module TweetsHelper
  def profile_pic(tweet)
    image_tag tweet.tweeter_profile_image_url.to_s, class: 'tweet-profile-pic'
  end

  def link_to_tweeter(tweet)
    link_to tweet.tweeter_name, "https://twitter.com/#{tweet.tweeter_screen_name}", class: 'tweeter_link', target: '_blank'
  end

  def link_to_tweet_id(tweet)
    link_to "#{time_ago_in_words tweet.tweet_date} ago",
            "https://twitter.com/#{tweet.tweeter_screen_name}/status/#{tweet.tweet_id}",
            class: 'tweet_link', target: '_blank'
  end

  def text_to_true_link(tweet_text)
    urls = tweet_text.scan(/http\S*/)
    urls.each do |url|
      tweet_text.gsub!(url, "<a href=#{url} target='_blank'>#{url}</a>")
    end
    tweet_text.html_safe
  end
end