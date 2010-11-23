require 'sqlite3'

# this class stores all kinds of helper stuff.
class Utils
   def Utils.db
      return @@db
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
end
