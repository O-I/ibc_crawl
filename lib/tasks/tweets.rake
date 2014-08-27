require_relative 'rake_helper'

namespace :ibc do
  desc 'Get a web of tweets starting at the "origin"'
  task :crawl, [:deg, :last_n] => :environment do |t, args|
    MAX = 200
    degree_of_separation = args[:deg] || 7
    n_tweets = args[:last_n] || 3
    iterations = 0
    tweets = []
    now_size, prev_size = 1, 0
    bucketeers = []
    priors = ['ckgolfsrq']
    options = { count: MAX }
    # Chris Kennedy's ice bucket challenge (AKA the origin)
    tweets << $client.status(489119505453297665)
    puts 'Commencing IBC crawl. This will take a while...'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')
    degree_of_separation.times do |degree|
      puts "\nDEGREE OF SEPARATION #{degree + 1}\n\n"
      to_do = now_size - prev_size
      prev_size = now_size

      tweets.last(to_do).reverse.each do |tweet|
        begin
          bucketeers |= tweet.attrs[:entities][:user_mentions]
                             .map{ |b| b[:screen_name] }
        rescue => e
          puts "The exception is #{e.message}."
          next
        end
      end

      bucketeers -= priors

      bucketeers.each do |b|
        puts "Processing bucketeer #{iterations}: #{b}..."
        begin
          tweets |= $client.user_timeline(b, options).select do |t|
            t.text =~ /ice\s?bucket|tak(e|es|ing)\s?ice/i
          end.last(n_tweets)
          iterations += 1
          sleep 1.minute if iterations % 10 == 0
        rescue => e
          puts "The exception is #{e.message}."
          next
        end
      end

      now_size = tweets.size

      priors |= bucketeers

    end

    puts
    puts '*** INSERTING TWEETS INTO DATABASE ***'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')
    tweets.each.with_index do |tweet, index|
      begin
        puts "Adding tweet #{index} to database"
        RakeHelper::creator(tweet)
      rescue => e
        puts "Something went wrong importing tweet #{index}. The exception is #{e.message}."
        next
      end
    end

    puts
    puts '*** DATABASE UPDATE COMPLETE ***'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')
  end
end