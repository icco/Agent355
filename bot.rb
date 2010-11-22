#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'isaac'
require 'yaml'
require 'json'
require 'net/http'

# For .lp
require 'json'
require 'net/http'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac

# First we parse config.yml and set things up.
settings = {}
configure do |c|
   # defaults
   settings = {
      'realname' => 'Test',
      'nick' => "mind_flayer2",
      'ns_pw' => "",
      'server' => 'irc.freenode.net',
      'port' => 6667,
      'exempt' => [],
      'channel' => '#cplug-bottest',
      'logger' => nil
   }

   if File.exists? './config.yml'
      File.open(File.expand_path('./config.yml'), 'r') {|yf|
         new_settings = YAML::load( yf )
         if new_settings
            new_settings.each_pair {|key, val| settings[key] = val }
         end
      }
   end

   settings['logger'] = Logger.new("#{settings['nick']}.log", 'daily')

   # then match our config settings with isaac's
   c.nick = settings['nick'] 
   c.server = settings['server']
   c.port = settings['port']
   c.realname = settings['realname']
   c.verbose = false
   c.version = 'Agent 355 v0.42'
   c.logger = settings['logger']
end

# Now we define what we are going to do on connect.
on :connect do
   # we will only be able to op if we auth with Nickserv
   if settings['ns_pw']
      msg 'NickServ', "IDENTIFY #{settings['nick']} #{settings['ns_pw']}"
   end

   join settings['channel']
end

# this is the function that builds our mature language regex.
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

   leet = { 
      "a" => "4@",
      "b" => "68",
      "c" => "(",
      "e" => "3",
      "g" => "6",
      "i" => "1!",
      "i" => "17",
      "o" => "0",
      "p" => "9",
      "s" => "5$",
      "t" => "7+",
   }

   words.map! {|w|
      w.split('').map {|c|
         c.gsub!(Regexp.compile("[#{leet.keys.to_s}]")) {|m| 
            "[#{Regexp.escape(leet[m]) + m}]" }
         c + '+[^A-Za-z]*'
      }
   }

   match_words = words.clone
#   words.each {|w|
#      match_words << w.split('').join('+[^A-Za-z]*')
#   }

   rex = match_words.join('|')

   return Regexp.new("(#{rex})", Regexp::EXTENDED|Regexp::IGNORECASE)
end

# parses all mesages for the regex built in mature.
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

# .mature
on :channel, /^\.mature$/ do
   msg nick, "Mature Regex: #{mature.inspect.tr("\n", "")}"
end

# .source
on :channel, /^\.source$/ do
   msg channel, "My source is at http://github.com/icco/Agent355."
end

# .lp
on :channel, /^\.lp (\w+)$/ do
   lp_user = match[0]
   api = "b25b959554ed76058ac220b7b2e0a026"

   base_url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks"
   url = "#{base_url}&limit=1&user=#{lp_user}&api_key=#{api}&limit=1&format=json"
   resp = Net::HTTP.get_response(URI.parse(url))
   result = JSON.parse(resp.body)

   if !result.nil? && !result['recenttracks'].nil? && !result['recenttracks']['track'].nil?
      track = result['recenttracks']['track']
      title =  track[0].nil? ? track['name'] : track[0]['name']
      artist = track[0].nil? ? track['artist']['#text'] : track[0]['artist']['#text']

      msg channel, "#{lp_user} is listening to \"#{title}\" by #{artist}."
   else
      msg channel, "#{lp_user} is not a valid last.fm user."
   end
end

# .help
on :channel, /^\.help$/ do
   msg channel, "I respond to the following: .lp, .mature, .source, .help"
end
