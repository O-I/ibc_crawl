# IBC Crawl

Test crawling the ALS Ice Bucket Challenge phenomenon on Twitter.

## Motivation

The goal is to visualize how the Ice Bucket Challenge went viral in late summer 2014. There are several lists online that try to flesh out a connected graph, but it is a difficult task to make such a list exhaustive even if the labor is crowdsourced.

This is one experiment in automating the process of gathering that information by

1. Harvesting tweets about the Ice Bucket Challenge that contain information about who challenged whom and links to media of accepted challenges
2. Making it easier to sift through those tweets to verify the accuracy of relevant information

## Development

### Basics

This assumes development on Mac OS X. Things you should have installed are listed below with the easiest way to get them if you do not:

- Homebrew

`$ ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"`

- Git

`$ brew install git`

- RVM

`$ curl -sSL https://get.rvm.io | bash -s stable`

- PostgreSQL

Download from [here](https://github.com/PostgresApp/PostgresApp/releases/download/9.3.4.2/Postgres-9.3.4.2.zip), drag to the applications folder, and double-click.

If Terminal responds to `brew`, `git`, `rvm`, and `psql`, continue on.

### Setup

Clone the app and `bundle`:

```
$ git clone git@github.com:O-I/ibc_crawl.git
$ cd ibc_crawl
$ bundle install
```

You'll need Twitter keys. Get them [here](https://dev.twitter.com). Then create a `.env` file in the root that mimics the structure of `.env_example` using your development keys.

Create and migrate the database:

```
$ rake db:create
$ rake db:migrate
```

Currently, there is only one rake task to seed the database, `rake ibc:crawl`. It starts with Chris Kennedy's completed challenge (considered to be the origin of the phenomenon) and iteratively collects the at most 3 earliest tweets (of the last 200) of all mentioned users who reference the ice bucket challenge.

The task defaults to 7 degrees of separation (about 900 people and 1700 tweets) which, with the pauses I have built in for rate limiting, runs fairly slow for my taste. To experiment with a smaller initial set of tweets, say, 5 degrees of separation out with only the earliest tweet per user mentioned, run `rake ibc:crawl[5,1]`.

Run `rails s` and point your browser to [http://localhost:3000](http://localhost:3000) and you should be good to go!

## To do

Although it's interesting to use Chris Kennedy's tweet as the sole seed for a deep crawl, it's probably better to start with a sizable list of known Ice Bucket Challenge participants and only go a few iterations deep.

I'm working on testing a task that implements the latter, breadth-first approach both for Twitter and the Facebook Graph API. Hopefully, I can use a combination of overlapping user mention data and post dates to tease out who challenged whom automagically.