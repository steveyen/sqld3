#!/usr/bin/env ruby

$keywords = {}

def rule(name, *rest)
  print "#{name} =\n"
  rest.flatten.each do |x|
    $keywords[x] = true if x.class == String and x.match(/^[A-Z]+$/)
    print "#{x} "
  end
  print "\n\n"
end

def either(*rest)
  r = []
  rest.each {|x| r << x; r << '/' }
  ["("] + r[0..-2] + [")"]
end

def stack(*rest)
  return rest if rest.length <= 1
  return ["("] + rest + [")"]
end

def line(*rest)
  return stack(*rest)
end

def loop(*rest)
  return ["("] + rest + [")+"]
end

def toploop(*rest)
  return loop(*rest)
end

def tailbranch(*rest)
  return rest
end

def opt(*rest)
  return [rest, "?"] if rest.length <= 1
  return ["("] + rest + [")?"]
end

def optx(*rest)
  return opt(*rest)
end

# ----------------------------------------

print "// generated pegjs\n"
print "\n"
print "start = sql_stmt_list\n"
print "\n"

grammar = ARGV[0]

load grammar

# ----------------------------------------

print """
dot = '.'
comma = ','
semicolon = ';'
minusminus = '--'
minus = '-'
plus = '+'
lparen = '('
rparen = ')'
star = '*'
newline = '\\n'
anything_except_newline = [^\\n]*
comment_beg = '/*'
comment_end = '*/'
anything_except_comment_end = .* & '*/'
whitespace = [ \\t]*
nil = ''
"""

print "\n"

$keywords.keys.sort.each do |keyword|
  print "#{keyword} = whitespace \"#{keyword}\"\n"
end

