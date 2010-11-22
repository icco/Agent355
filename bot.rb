#!/usr/bin/env ruby

require 'rubygems'
require 'isaac'

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

   return Regexp.new("(#{rex})",  Regexp::EXTENDED|Regexp::IGNORECASE)
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
      'channel' => '#bottest'
   }

   File.open(File.expand_path('./config.yml'), 'r') {|yf|
      new_settings = YAML::load( yf )
      if new_settings
         new_settings.each_pair {|key, val|
            settings[key] = val
         }
      end
   }

   c.nick = settings['nick'] 
   c.server = settings['server']
   c.port = settings['port']
   c.realname = settings['realname']
   c.verbose = false
   c.version = 'Agent 355 v0.42'
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
   puts "#{nick}: #{action} => #{match.inspect}"

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
