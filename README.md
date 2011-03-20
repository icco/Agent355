# Agent 355

A bot to control the insanity that is taking place in #cplug.

Requires the following gems to run.

 * [isaac][i]
 * [json][j]
 * [sqlite3-ruby][s] - apt-get install `libsqlite3-dev` and `ruby-dev` first if you are on debian
 * [daemons][d]

[![Agent 355](https://github.com/icco/Agent355/raw/master/Y_-_The_Last_Man_013.jpg)](https://secure.wikimedia.org/wikipedia/en/wiki/List_of_Y:_The_Last_Man_characters#Agent_355)

[i]: https://github.com/icco/isaac
[j]: http://flori.github.com/json/
[s]: https://github.com/luislavena/sqlite3-ruby
[d]: http://daemons.rubyforge.org/

## TODO

 * timed bans
 * Autopost on the following
    * .cplug
    * .csl

 * Logging of some sort...
   * not sure if we want this...

 * Auto-Reconnect

 * other possible features
   * !8ball <to predict>
   * !calc <term>
   * !ctcp <user>
   * !man <command>
   * help commands
   * man commands
   * man purpose
   * man rating

 * Develop a system that loads in classes instead of defining everything here.

## Contributing

Fork and then send me a pull request. If it is a new feature make sure to add
it to .help and explain what the intended output is.

## License

Copyright (c) 2010 Cal Poly Linux Users Group

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

