require "rubygems"

require 'curb'
require 'json'

#https://plusone.google.com/_/+1/fastbutton?url=http%3A%2F%2Fantyweb.pl%2Fzakaz-odwiedzania-zagranicznych-stron-www-na-bialorusi-idea-propagowania-internetu-panstwowego%2F&count=true
#https://github.com/pell/GooglePlusCounter | by pëll dalipi | http://antiperson.de | ®: use it just as you like it.

def count_gplus(url)
  jsonstring = '[{"method":"pos.plusones.get","id":"p","params":{"nolog":true,"id":"' + url +'","source":"widget","userId":"@viewer","groupId":"@self"},"jsonrpc":"2.0","key":"p","apiVersion":"v1"}]'

  c = Curl::Easy.http_post("https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ", jsonstring) do |curl|
      curl.headers['Accept'] = 'application/json'
      curl.headers['Content-Type'] = 'application/json'
      curl.headers['Api-Version'] = '2.2'
  end

  response = JSON.parse(c.body_str)
  puts response
  if response[0]['error'] == nil
    return false
  else
    return count = response[0]['result']['metadata']['globalCounts']['count'].round
  end
end

puts count_gplus("http://jogger.pl")