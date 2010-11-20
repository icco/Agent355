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

mature = /\b
      (
        ass
       |asses
       |asshole
       |assholes
       |badass
       |bastard
       |beastial
       |beastiality
       |beastility
       |bestial
       |bestiality
       |bitch
       |bitcher
       |bitchers
       |bitches
       |bitchin
       |bitching
       |blowjob
       |blowjobs
       |clit
       |cock
       |cocks
       |cocksuck 
       |cocksucked 
       |cocksucker
       |cocksucking
       |cocksucks 
       |cum
       |cummer
       |cumming
       |cums
       |cumshot
       |cunilingus
       |cunillingus
       |cunnilingus
       |cunt
       |cuntlick
       |cuntlicker
       |cuntlicking
       |cunts
       |cyberfuc
       |cyberfuck
       |cyberfucked
       |cyberfucker
       |cyberfuckers
       |cyberfucking
       |damn
       |dildo
       |dildos
       |dumbshit
       |ejaculate
       |ejaculated
       |ejaculates
       |ejaculating
       |ejaculatings
       |ejaculation
       |fag
       |fagging
       |faggot
       |faggs
       |fagot
       |fagots
       |fags
       |felatio
       |fellatio
       |fingerfuck
       |fingerfucked
       |fingerfucker
       |fingerfuckers
       |fingerfucking
       |fingerfucks
       |fistfuck
       |fistfucked
       |fistfucker
       |fistfuckers
       |fistfucking
       |fistfuckings
       |fistfucks
       |fuck
       |fucked
       |fucker
       |fuckers
       |fuckin
       |fucking
       |fuckings
       |fuckme
       |fucks
       |fuk
       |fuks
       |gangbang
       |gangbanged
       |gangbangs
       |gaysex
       |goddamn
       |(?:god.damn)
       |(?:god.dammit)
       |hell
       |horniest
       |horny
       |hotsex
       |jack.off
       |jerk.off
       |jism
       |jiz
       |jizm
       |kock
       |kondum
       |kondums
       |kum
       |kummer
       |kumming
       |kums
       |kunilingus
       |lust
       |lusting
       |mothafuck
       |mothafucka
       |mothafuckas
       |mothafuckaz
       |mothafucked
       |mothafucker
       |mothafuckers
       |mothafuckin
       |mothafucking
       |mothafuckings
       |mothafucks
       |motherfuck
       |motherfucked
       |motherfucker
       |motherfuckers
       |motherfuckin
       |motherfucking
       |motherfuckings
       |motherfucks
       |nigger
       |niggers
       |orgasim
       |orgasims
       |orgasm
       |orgasms
       |phonesex
       |phuk
       |phuked
       |phuking
       |phukked
       |phukking
       |phuks
       |phuq
       |piss
       |pissed
       |pisser
       |pissers
       |pisses
       |pissin
       |pissing
       |pissoff
       |porn
       |porno
       |pornography
       |pornos
       |prick
       |pricks
       |pussies
       |pussy
       |pussys
       |shit
       |shited
       |shitfull
       |shiting
       |shitings
       |shits
       |shitted
       |shitter
       |shitters
       |shitting
       |shittings
       |shitty
       |slut
       |sluts
       |smut
       |spunk
       |twat
      )
    \b/xi

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

# returns a quote. Should probably pull from crackquotes, but that could cause a self-ban
on :channel, /\.quote/ do
   msg channel, "#{nick} requested a quote..."
end

on :channel, /\.source/ do
   msg channel, " -- My source is at https://github.com/icco/Agent355."
end
