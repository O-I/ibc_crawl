class Tweet < ActiveRecord::Base
  serialize :hashtags, Array
  serialize :urls, Array
  serialize :user_mentions, Array
  serialize :tweeter_profile_image_url, Addressable::URI

  validates_uniqueness_of :tweet_id

  self.per_page = 25

  include PgSearch
  pg_search_scope :seek,
    against: { tweeter_name: 'A', tweeter_screen_name: 'B', tweet_text: 'C' },
    using: { tsearch: { dictionary: 'english', prefix: true } },
    ignoring: :accents

  def self.search(query)
    query.present? ? seek(query) : all
  end
end