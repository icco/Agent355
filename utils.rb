require 'sqlite3'

# this class stores all kinds of helper stuff.
class Utils
   def Utils.db
      return @@db
   end

   def Utils.getSeen user
      return (self.getKeyPair user, 'seens').to_i
   end

   def Utils.markSeen user
      return self.storeKeyPair user, Time.now.to_i, 'seens'
   end

   def Utils.getDefine key
      return self.getKeyPair key, 'defines'
   end

   def Utils.storeDefine key, value
      return self.storeKeyPair key, value, 'defines'
   end

   def Utils.storeKeyPair key, value, table
      sql = <<-SQL
         INSERT OR REPLACE INTO #{table} (key, value) VALUES (:k, :v);
      SQL

      out = Utils.db.execute(sql, :k => key, :v => value)

      return out
   end

   def Utils.getKeyPair key, table
      sql = <<-SQL
         SELECT value
         FROM #{table} 
         WHERE key = ?;
      SQL

      return Utils.db.get_first_value(sql, key)
   end

   # nice little howto for sqlite in ruby
   # http://viewsourcecode.org/why/hacking/aQuickGuideToSQLite.html
   # http://www.sqlite.org/lang.html
   def Utils.buildDB filename
      @@db = SQLite3::Database.new(filename)

      ['defines', 'seens', 'bans'].each {|tbl|
         Utils.db.execute <<-SQL
            CREATE TABLE IF NOT EXISTS #{tbl} (
               key VARCHAR(255) PRIMARY KEY,
               value TEXT
            );
         SQL
      }
   end

   def Utils.mature_words
      return [
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
   end

   # this is the function that builds our mature language regex.
   def Utils.mature_regex words
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
         }.join
      }

      return Regexp.new("(#{words.join('|')})", Regexp::EXTENDED|Regexp::IGNORECASE)
   end

   def Utils.rss feed
      require 'rss'

      rss = RSS::Parser.parse(open(feed).read(), false).items[0]

      ts = Utils.time_since rss.pubDate

      return "\"#{rss.title}\" #{ts} -- #{rss.link}"
   end

   def Utils.twitter username
      params = "?screen_name=#{username}&count=1&trim_user=true"
      json = "http://api.twitter.com/1/statuses/user_timeline.json#{params}"
      url = URI.parse(json)
      resp = Net::HTTP.get_response(url)
      data = resp.body
      result = JSON.parse(data)

      ts = Utils.time_since Time.parse(result[0]['created_at'])

      return "\"#{result[0]['text']}\" #{ts} -- http://twitter.com/#{username}"
   end

   # pass in a time object 
   def Utils.time_since time
      distance = Time.now - time

      out = case distance
            when 0 .. 59 then "#{distance} seconds ago"
            when 60 .. (60*60) then "#{distance/60} minutes ago"
            when (60*60) .. (60*60*24) then "#{distance/(60*60)} hours ago"
            when (60*60*24) .. (60*60*24*30) then "#{distance/((60*60)*24)} days ago"
            else time.strftime("%m/%d/%Y")
            end

      return out.sub(/^1 (\w+)s ago$/, '1 \1 ago')
   end
end

