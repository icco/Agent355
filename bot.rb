#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'isaac'
require 'yaml'
require 'json'
require 'uri'
require 'open-uri'
require 'net/http'

require File.expand_path('utils', File.dirname(__FILE__))

# This is a "fun" little IRC bot written in ruby using the [isaac][i]
# framework. Use icco's fork if you want good times.
#
# [i]: https://github.com/icco/isaac

# First we parse config.yml and set things up.
settings = {}
configure do |c|
   # defaults -- Change in config.yml, not here
   settings = {
      'realname' => 'Test',
      'nick' => "Agent355Test",
      'ns_pw' => "",
      'server' => 'irc.freenode.net',
      'port' => 6667,
      'exempt' => [],
      'channel' => '#bottest',
      'db' => 'botDB.db',
      'logger' => 'bot.log',
   }

   config_file = File.expand_path('./config.yml', File.dirname(__FILE__))
   if File.exists? config_file
      File.open(config_file) {|yf|
         new_settings = YAML::load( yf )
         if new_settings
            new_settings.each_pair {|key, val| settings[key] = val }
         end
      }
   end

   Utils.buildDB File.expand_path(settings['db'], File.dirname(__FILE__))

   # then match our config settings with isaac's
   c.nick = settings['nick']
   c.server = settings['server']
   c.port = settings['port']
   c.realname = settings['realname']
   c.verbose = true
   c.version = 'Agent 355 v0.42'

   # Comment to print to STDOUT instead of logging.
   settings['logger'] = "log/#{settings['nick']}.log"
   c.logger = Logger.new(File.expand_path(settings['logger'], File.dirname(__FILE__)), 'daily')
end

# Now we define what we are going to do on connect.
on :connect do
   join settings['channel']

   # we will only be able to op if we auth with Nickserv
   # And we can only op if we are in the channel
   if settings['ns_pw']
      msg 'NickServ', "IDENTIFY #{settings['nick']} #{settings['ns_pw']}"
      msg 'ChanServ', "op #{settings['channel']}"
   end

   log "Joining #{settings['channel']}."
end

# Auto-rejoin
on :kick do
   sleep 1
   log "#{nick} was kicked!"
   join settings['channel']
   log "Joining #{settings['channel']}."
end

# parses all mesages for the regex built in mature.
on :channel, Utils.mature_regex(Utils.mature_words) do
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
   msg channel, "Mature words I kick on: #{Utils.mature_words.inspect}"
end

# .source
on :channel, /^\.source$/ do
   msg channel, "My source is at https://github.com/icco/Agent355."
end

# .lp
on :channel, /^\.lp (\w+)$/ do
   lp_user = match[0]

   msg channel, Utils.lastplayed(lp_user)
end

on :channel, /^\.lp$/ do
   msg channel, Utils.lastplayed(nick)
end

# .help
on :channel, /^\.help$/ do
   msg channel, "I respond to the following: .lp, .mature, .source, .help, .define, .moo, .seen, .cplug, .csl, .wiki, .image"
end

# .define
on :channel, /^\.define +([\w#]+) +(.+)$/ do
   define = match[0]
   txt = match[1]
   exists = (Utils.getDefine define)

   Utils.storeDefine define, txt

   if exists
      message = "Replacing definition for '#{define}."
   else
      message = "'#{define} has been defined."
   end

   msg channel, message
end

# for things that have been defined.
on :channel, /^\'([\w#]+)$/ do
   txt = Utils.getDefine match[0]

   if txt
      msg channel, txt
   else
      log "#{match[0]} not defined"
   end
end

# .seen
on :channel, /^\.seen (\S+)$/ do
   date = Utils.getSeen match[0]

   if date > 0
      msg channel, "#{match[0]} was last seen on #{Time.at(date)}."
   else
      msg channel, "I have never seen #{match[0]}."
   end
end

on :channel, /^\.moo(( (\S+)$)|$)/ do
   user = match[2].nil? ? nick : match[2]
   msg channel, "#{nick} shoots milk out of their teats at #{user}."
end

on :channel, /^\.cplug$/ do
   msg channel, Utils.rss("http://cplug.org/feed/")
end

on :channel, /^\.csl$/ do
   msg channel, Utils.twitter("csl_status")
end

# Given .image word, return an image.
on :channel, /^\.image (.+)$/ do
   phrase = URI.escape(match[0])
   url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&safe=active&q=#{phrase}"

   data = open(url)
   obj = JSON.parse(data.string)
   images = obj["responseData"]["results"]
   if !images.empty?
      image = images.sample
      msg channel, image["unescapedUrl"]
   else
      msg channel, "No images found for #{phrase}."
   end
end

# search wikipedia with .wiki
on :channel, /^\.wiki (.+)$/ do
  term = URI.escape(match[0])
  url = "http://en.wikipedia.org/w/api.php?action=opensearch&search=#{term}&format=json"

  data = open(url)
  obj = JSON.parse(data.string)
  if !obj[1].empty?
     msg channel, "http://en.wikipedia.org/wiki/#{URI.escape(obj[1][0])}"
  else
     msg channel, "Found nothing."
  end
end

# .commit -> random commit msg
on :channel, /^\.commit$/ do
   url = "http://whatthecommit.com/index.txt"
   out = open(url)
   msg channel, out.string if !out.nil?
end

# .fortune
on :channel, /^\.fortune$/ do
   url = "http://www.fortunefortoday.com/getfortuneonly.php"
   out = open(url)

   if !out.nil?
      out.readlines.each do |str|
         str = str.rstrip
         msg channel, str if !str.empty?
      end
   end
end

# log users.
on :channel do
   Utils.markSeen nick
end
