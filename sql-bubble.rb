#!/usr/bin/env ruby

# Process the sql-bubble.txt into a sql.pegjs
#
bubble = ARGV[0] || 'sql-bubble.txt'

lines = File.open(bubble, "r").readlines
lines = lines.reject {|x| x.match /^\s*\#/} # Comments.
lines = lines.reject {|x| x.match /^$\s+/}  # Whitespace.
lines = lines.map {|x| x.gsub(/\./, 'dot')}
lines = lines.map {|x| x.gsub(/\=/, 'equal')}
lines = lines.map {|x| x.gsub(/\+/, 'plus')}
lines = lines.map {|x| x.gsub(/ \-/, ' minus')}
lines = lines.map {|x| x.gsub(/\-\-/, 'minusminus')}
lines = lines.map {|x| x.gsub(/\-/, '_')}    # Underscores.
lines = lines.map {|x| x.gsub(/^set all_graphs/, 'sql')}
lines = lines.map {|x| x.gsub(/,/, 'comma')}
lines = lines.map {|x| x.gsub(/\/\*/, 'comment_beg')}
lines = lines.map {|x| x.gsub(/\*\//, 'comment_end')}
lines = lines.map {|x| x.gsub(/\*/, 'star')}
lines = lines.map {|x| x.gsub(/\;/, 'semicolon')}
lines = lines.map {|x| x.gsub(/\(/, 'lparen')}
lines = lines.map {|x| x.gsub(/\)/, 'rparen')}
lines = lines.map {|x| x.gsub(/\{/, '(')}
lines = lines.map {|x| x.gsub(/\}/, ')')}

print lines

