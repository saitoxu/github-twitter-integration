require 'sinatra'
require 'twitter'
require 'json'

get '/' do
  'working'
end

post '/payload' do

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  end
  count = 0
  prefix = 'POST:'
  commits = JSON.parse(request.body.read)['commits']

  for commit in commits do
    message = commit['message']
    if message.start_with?(prefix)
      title = message.sub(/${prefix}/, '').strip
      addedFiles = commit['message']
      for added in addedFiles do
        if md = added.match(/([0-9]{4})-([0-9]{2})-([0-9]{2})-(.*).md/)
          year  = md[1]
          month = md[2]
          day   = md[3]
          page  = md[4] + '.html'
          url = ['http://saitoxu.io/blog/', year, month, day, page].join('/')

          client.update(title + "\n" + url)
          count += 1
        end
      end
    end
  end
  puts "#{count} tweet(s) posted."

end
