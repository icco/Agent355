#!/usr/bin/env ruby

require 'rubygems'
require 'isaac'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac

# This should eventualy be pulled from YAML.
settings = {
   'realname' => 'Nat Welch',
   'nick' => "Agent355",
   'server' => 'irc.freenode.net',
}

# This is here for now, until the regex is nailed down
def mature
   words = [
      'fag',
      'nig',
      'chink',
      'gook'
   ]

   rex = words.join('|')

   return Regexp.new("(#{rex})",  Regexp::EXTENDED|Regexp::IGNORECASE)
end

configure do |c|
   c.nick = settings['nick'] 
   c.server = settings['server']
   c.port = 6667
   c.realname = settings['realname']
   c.verbose = true
   c.version = 'Agent 355 v0.42'
end

on :connect do
   msg 'NickServ', "IDENTIFY #{settings['nick']} #{settings['ns_pw']}"
   join "#icco"
end

on :private, /^t (.*)/ do
   msg nick, "You said: #{match.inspect}"
end

on :channel, mature do
   msg channel, "This is not okay: #{match.inspect}."
end

on :channel, /^\.mature$/ do
   msg nick, "Mature Regex: #{mature.inspect.tr("\n", "").tr(' ', '')}"
end

# returns a quote. Should probably pull from crackquotes, but that could cause a self-ban
on :channel, /\.quote/ do
   msg channel, "#{nick} requested a quote..."
end

on :channel, /\.source/ do
   msg channel, " -- My source is at https://github.com/icco/Agent355."
end
