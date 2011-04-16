#!/usr/bin/env ruby

$grammar  = ARGV[0]
$grammarx = ARGV[1] || 'bubble-to-pegjs_ex.rb'
$keywords = {}
$override = {}

# ----------------------------------------

def rule(name, *rest)
  print "#{name} =\n"
  if $override[name]
    print "#{$override[name]}\n"
  else
    rest.flatten.each do |x|
      $keywords[x] = true if x.class == String and x.match(/^[A-Z]+$/)
      print "#{x} "
    end
    print "\n\n"
  end
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

def tailbranch(*rest) # TODO.
  return rest
end

def opt(*rest)
  return ["("] + rest + [")?"]
end

def optx(*rest)
  return opt(*rest)
end

# ----------------------------------------

$header = <<-EOS
// generated pegjs, from #{$grammar} and #{$grammarx}

start = sql_stmt_list
EOS

# ----------------------------------------

$extra = <<-EOS
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
string_literal = '\"' (escape_char / [^"])* '\"'
escape_char = '\\\\' .
nil = ''

whitespace = [\\s]*

unary_operator = '-' / '+' / '~' / 'NOT'
binary_operator =
  '||'
  / '*' / '/' / '%'
  / '+' / '-'
  / '<<' / '>>' / '&' / '|'
  / '<' / '<=' / '>' / '>='
  / '=' / '==' / '!=' / '<>'
  / 'IS' / 'IS NOT' / 'IN' / 'LIKE' / 'GLOB' / 'MATCH' / 'REGEXP'
  / 'AND'
  / 'OR'

digit = [0-9]
decimal_point = dot
equal = '='

name = [A-Za-z0-9_]+
database_name = name
table_name = name
table_alias = name
table_or_index_name = name
new_table_name = name
index_name = name
column_name = name
column_alias = name
foreign_table = name
savepoint_name = name
collation_name = name
trigger_name = name
view_name = name
module_name = name
module_argument = name
bind_parameter = name
function_name = name
pragma_name = name

error_message = string_literal

CURRENT_TIME = 'now'
CURRENT_DATE = 'now'
CURRENT_TIMESTAMP = 'now'

blob_literal = string_literal

end_of_input = ''
EOS

# ----------------------------------------

load $grammarx

print "#{$header}\n"

load $grammar

print "#{$extra}\n"

$keywords.keys.sort.each do |keyword|
  print "#{keyword} = whitespace \"#{keyword}\"\n"
end

