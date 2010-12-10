#!/bin/env ruby

require 'rubygems'
require 'daemons'

# Basically you can run this script with stop, start, restart and run. It will
# put the bot in the background.

Daemons.run('bot.rb')
