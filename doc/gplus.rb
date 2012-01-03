require "curb"
require "json"

JSON.parse((Curl::Easy.http_post("https://clients6.google.com/rpc?key=AIzaSyCKSbrvQasunBoV16zDH9R33D88CeLr9gQ',{"method"=>"pos.plusones.get",'id"=>"p',"params"=>{"nolog"=>true,"id"=>"!->URL"widget",'userId"=>"@viewer",'groupId"=>"@self"},"jsonrpc"=>"2.0′,"key"=>"p',"apiVersion"=>"v1′}]){|curl|curl.headers['Accept']="application/json";curl.headers['Content-Type']="application/json";curl.headers['Api-Version']="2.2′}).body_str)['result']['metadata']['globalCounts']['count']