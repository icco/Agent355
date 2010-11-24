#!/usr/bin/env ruby

require 'rubygems'
require 'logger'
require 'isaac'
require 'yaml'
require 'json'
require 'net/http'

require 'utils'

# This is a "fun" little IRC bot written in ruby using the [isaac][i] framework.
#
# [i]: https://github.com/ichverstehe/isaac

# First we parse config.yml and set things up.
settings = {}
configure do |c|
   # defaults
   settings = {
      'realname' => 'Test',
      'nick' => "Agent355Test",
      'ns_pw' => "",
      'server' => 'irc.freenode.net',
      'port' => 6667,
      'exempt' => [],
      'channel' => '#bottest',
      'db' => 'botDB.db',
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

   Utils.buildDB settings['db']

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
   msg nick, "Mature words I kick on: #{Utils.mature_words.inspect}"
end

# .source
on :channel, /^\.source$/ do
   msg channel, "My source is at https://github.com/icco/Agent355."
end

# .lp
on :channel, /^\.lp (\w+)$/ do
   lp_user = match[0]
   api = "c8a55898b287950c836a1af12d91ce7d"

   base_url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks"
   url = "#{base_url}&user=#{lp_user}&api_key=#{api}&limit=1&format=json"
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
   msg channel, "I respond to the following: .lp, .mature, .source, .help, .define, .seen"
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

# log users.
on :channel do
   Utils.markSeen nick
end
