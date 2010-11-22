#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'isaac'
require 'yaml'

# For .lp
require 'json'
require 'net/http'

# For .lp
require 'json'
require 'net/http'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac

settings = {}

# This is here for now, until the regex is nailed down
def mature
   words = [
      'chink',
      'chnk',
      'fag',
      'gook',
      'niga',
      'nigar',
      'nigga',
      'niggar',
      'nigger',
      'niggr',
   ]

   match_words = words.clone
   words.each {|w|
      match_words << w.split('').join('+[^A-Za-z]*')
   }

   match_words << 'f+\W*[a@]+\W*g'

   rex = match_words.join('|')

   return Regexp.new("(#{rex})", Regexp::EXTENDED|Regexp::IGNORECASE)
end

configure do |c|
   # defaults
   settings = {
      'realname' => 'Nat Welch',
      'nick' => "Agent355",
      'ns_pw' => "",
      'server' => 'irc.freenode.net',
      'port' => 6667,
      'exempt' => [],
      'channel' => '#bottest',
      'logger' => nil
   }

   File.open(File.expand_path('./config.yml'), 'r') {|yf|
      new_settings = YAML::load( yf )
      if new_settings
         new_settings.each_pair {|key, val| settings[key] = val }
      end
   }

   settings['logger'] = Logger.new("#{settings['nick']}.log", 'daily')

   c.nick = settings['nick'] 
   c.server = settings['server']
   c.port = settings['port']
   c.realname = settings['realname']
   c.verbose = true
   c.version = 'Agent 355 v0.42'
   c.logger = settings['logger']
end

on :connect do
   if settings['ns_pw']
      msg 'NickServ', "IDENTIFY #{settings['nick']} #{settings['ns_pw']}"
   end

   join settings['channel']
end

on :channel, mature do
   exempt = settings['exempt'].include? nick
   action = "kicked"
   message = "Hi #{nick}. You've been #{action} because the following matched my mature language regex: #{match}."
   kick_msg = "That language is not ok in #cplug."

   # Log
   log "#{nick}: #{action} => #{match.inspect}"

   # Deal with them
   kick channel, nick, kick_msg if !exempt
   msg nick, message if !exempt
end

on :channel, /^\.mature$/ do
   msg nick, "Mature Regex: #{mature.inspect.tr("\n", "")}"
end

on :channel, /^\.source$/ do
   msg channel, "My source is at http://github.com/icco/Agent355."
end

on :channel, /^\.lp (\w+)$/ do
   lp_user = match[0]
   api = "b25b959554ed76058ac220b7b2e0a026"

   base_url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks"
   url = "#{base_url}&limit=1&user=#{lp_user}&api_key=#{api}&limit=1&format=json"
   resp = Net::HTTP.get_response(URI.parse(url))
   result = JSON.parse(resp.body)

   track = result['recenttracks']['track']
   title =  track[0].nil? ? track['name'] : track[0]['name']
   artist = track[0].nil? ? track['artist']['#text'] : track[0]['artist']['#text']

   msg channel, "#{lp_user} is listening to \"#{title}\" by #{artist}"
end
