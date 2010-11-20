#!/usr/bin/env ruby

require 'rubygems'
require 'isaac'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac

configure do |c|
   c.nick = "Agent355"
   c.server = "irc.freenode.net"
   c.port = 6667
   c.realname = 'Nat Welch'
   c.verbose = true
   c.version = 'Agent 355 v0.42'
end

helpers do
   def check
      msg channel, "Enforcing teh law in #{channel}"
   end
end

on :connect do
   msg 'NickServ', "identify #{password}"
   join "#icco"
end

on :private, /^t (.*)/ do
   msg nick, "You said: " + match[1]
end

on :channel, /quote/ do
   msg channel, "#{nick} requested a quote: 'Smoking, a subtle form of suicide.' - Vonnegut"
end

on :channel, /status/ do
   check
end
