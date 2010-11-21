#!/usr/bin/env ruby

require 'rubygems'
require 'isaac'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac


# This is here for now, until the regex is nailed down
def mature
   words = [
      'fag',
      'nigger',
      'niggar',
      'niggr',
      'chnk',
      'chink',
      'gook',
   ]

   spaced_words = words.clone
   seperators = "-. _"
   words.each {|w|
      seperators.each_char {|s|
         spaced_words << Regexp.escape(w.split('').join(s))
      }
   }

   rex = spaced_words.join('|')

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
   }

   File.open(File.expand_path('./config.yml'), 'a+') {|yf|
      new_settings = YAML::load( yf )
      new_settings.each_pair {|key, val|
         settings[key] = val
      }
   }

   c.nick = settings['nick'] 
   c.server = settings['server']
   c.port = settings['port']
   c.realname = settings['realname']
   c.verbose = true
   c.version = 'Agent 355 v0.42'

end

on :connect do
   if settings['ns_pw']
      msg 'NickServ', "IDENTIFY #{settings['nick']} #{settings['ns_pw']}"
   end

   join "#icco"
end

on :private, /^t (.*)/ do
   msg nick, "You said: #{match.inspect}"
end

on :channel, mature do
   action = "kicked"
   message = "Hi #{nick}. You've been #{action} because the following matched my mature language regex: #{match.inspect}."
   kick_msg = "That language is not ok in #cplug."
   msg channel, message
end

on :channel, /^\.mature$/ do
   msg nick, "Mature Regex: #{mature.inspect.tr("\n", "")}"
end

on :channel, /\.source/ do
   msg channel, "My source is at http://github.com/icco/Agent355."
end
