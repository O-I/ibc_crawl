require_relative 'rake_helper'

namespace :ibc do
  desc 'Create list of bucketeers from Wikipedia page'
  task bucket_list: :environment do

    source = 'http://en.wikipedia.org/wiki/List_of_Ice_Bucket_Challenge_participants'
    target = Rails.root.join('db/bucket_list.txt')
    html = Nokogiri::HTML(open(source))
    raw_bucket_list = html.css('.div-col li').map(&:text)
    bucket_list = raw_bucket_list.map { |name| name.split('[')[0] }.uniq

    File.open(target, 'w') do |file|
      bucket_list.each { |name| file.puts name }
    end
  end

  desc 'Add every name in bucket list to DB'
  task insert_bucketeers: :environment do
    source = Rails.root.join('db/bucket_list.txt')
    iteration = 0

    puts 'Adding listed bucketeers to database. This may take a while...'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')

    File.open(source).each_line do |name|
      identity = name.chomp.delete(%q{-,.('") })
      user = identity #$client.user_search(name).first.try(:screen_name) || identity
      iteration += 1
      puts "Adding bucketeer #{iteration}: #{user}"
      Bucketeer.create(name: name.chomp, identifier: user)
      # sleep 1.minute if iteration % 10 == 0
    end

    puts 'Bucketeer insertion into database successful.'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')
  end

  desc 'Get a web of tweets starting at the "origin"'
  task :crawl, [:deg, :last_n] => :environment do |t, args|
    MAX = 200
    degree_of_separation = args[:deg] || 7
    n_tweets = args[:last_n] || 3
    iterations = 0
    tweets = []
    now_size, prev_size = 1, 0
    bucketeers = []
    # priors = ['ckgolfsrq']
    priors = ['SharkGregNorman']
    options = { count: MAX }
    # Chris Kennedy's ice bucket challenge (AKA the origin)
    # tweets << $client.status(489119505453297665)
    # Greg Norman's ice bucket challenge (another origin)
    tweets << $client.status(485476752928432128)
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

  desc 'Fetch tweets of users mentioned not in DB yet'
  task continue_crawl: :environment do
    # these will need to be checked manually later !!!
    EXCLUDE = %w(juicebucket21 skovy14 _Smith24 HollySondersGC Harris_English nfl serenawilliams GottliebShow GeorgeWBush johnmellencamp TheSteveTisch Seahawks GabrielMacht john_sintic I_Am_Iman IndyStarSports NikkiWZPL bangordailynews themantz PeterBevacqua MayorBallard mmqb Chubbies ApartmentList EBled2 RadimVrbata17 BrewersFanCamp davestopera AlArrigoni NASCAR 22wiggins JManigat12 TMZ johnlegend ceeflashpee84 ChicagoBears AnaBoyerP GottaLaff JoeLieberman Bnuzzie liamgallagher vineapp Hot963 ForrestLTucker shawz15er mauricioislas Genosworld SavannahGuthrie Schwarzenegger JasonLaCanfora OITNB HasnaaZakir ValerieEstess als Pirates JayDeMarcus WillardKatsande Colt3FIVE Sternshow_JD Hatch89 MattRoth30 OnlyChrisRivers TJMShow chrisponce0313 weartv MiguelUnlimited ConcernedMom9 TalkingMomcents SoundersFC Chargers richarddeitsch Ms_Amazing31 onemanagement GERI1324FAN Michael_Nutter 6abc ESPNNFL PUMAGolf ILVOLOMIAMI AKnightNews5 sarahgqueenbee samiizoo lgmargolis soulcycle ChefRandyF PrimeKosher PoppyIsMyName cthagod YossiBenayoun15 DigiCellus rgmguy Ed_Clancy SportsCenter brendanshanahan msleamichele LeetBee mrBobbyBones Redskins ComplexMag Orioles cnewton753 Baron_Davis PujolsFive LeanneKoolFM DeanRichards RobForbesDJ LukeKuechly drewill44 kelleyri CutonDime25 TheKatieCook GMB Ben_Jones88 OLCoachCaldwell TomasStiglmayr OliverNorthFNC Missinfo SubaruCalgary Mets SenatorSessions SandyStimpson MLB BostonDotCom Edelman11 scott_speed 60Minutes rhilox)
    since_id = 484111074422042625 # Anna Rawson's tweet
    users_in_db = Tweet.pluck(:tweeter_screen_name).uniq
    users_mentioned = Tweet.pluck(:user_mentions)
    users_mentioned -= [[]]
    users_mentioned = users_mentioned.flatten.map { |u| u[:screen_name] }.uniq
    users_mentioned_not_in_db = (users_mentioned - users_in_db).uniq - EXCLUDE
    options = { count: 200, since_id: since_id }
    n_tweets = 3
    iterations = 0
    tweets = []

    puts 'Crawling Twitter for users mentioned not in DB. This may take a while...'
    puts Time.now.strftime('%I:%M%p on %a %m/%d/%Y')

    users_mentioned_not_in_db.each do |b|
      puts "Processing bucketeer #{b}..."
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

  desc 'Fetch a tweet manually by id'
  task :fetch_tweet, [:tweet_id] => :environment do |t, args|
    puts 'Enter the id of tweet:'
    tweet_id = args[:tweet_id]

    begin
      puts "Adding tweet #{tweet_id} to database"
      tweet = $client.status(tweet_id)
      RakeHelper::creator(tweet)
    rescue => e
      puts "Something went wrong importing tweet. The exception is #{e.message}."
      next
    end

    puts 'Tweet added'
  end
end