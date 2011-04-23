// Originally generated from...
//   1) sql-bubble.txt (from sqlite.org)
//   2) ./sql-bubble.rb sql-bubble.txt > tmp/rules.rb
//   3) ./bubble-to-pegjs.rb tmp/rules.rb bubble-to-pegjs_ex.rb > tmp/sql.pegjs
//
// Then, manually edited for pegjs suitability.
//
// Rules with indentation or with comments have manual edits.
//
start = sql_stmt_list

sql_stmt_list =
  r: ( whitespace ( sql_stmt )? whitespace semicolon )+
  { return filter(flatten(r, true), ';') }

sql_stmt =
  ( explain: ( EXPLAIN ( QUERY PLAN )? )?
    stmt: select_stmt )
  { return put_if_not_null(stmt, "explain", nonempty(flatstr(explain))) }

// For now, just concentrate of SELECT statements only, although
// we have all the machinery for all other statements, too.
//
// sql_stmt =
//  ( explain: ( EXPLAIN ( QUERY PLAN )? )?
//    stmt: (
//    alter_table_stmt
//    / analyze_stmt
//    / attach_stmt
//    / begin_stmt / commit_stmt
//    / create_index_stmt
//    / create_table_stmt
//    / create_trigger_stmt
//    / create_view_stmt
//    / create_virtual_table_stmt
//    / delete_stmt / delete_stmt_limited
//    / detach_stmt
//    / drop_index_stmt / drop_table_stmt / drop_trigger_stmt / drop_view_stmt
//    / insert_stmt
//    / pragma_stmt / reindex_stmt / release_stmt / rollback_stmt / savepoint_stmt
//    / select_stmt
//    / update_stmt / update_stmt_limited
//    / vacuum_stmt
//  ) )
//  { return { explain: flatstr(explain),
//             stmt: stmt } }

alter_table_stmt =
  ( ( ALTER TABLE table_ref )
    ( RENAME TO new_table_name )
    ( ADD ( COLUMN )? column_def ) )

analyze_stmt =
  ( ANALYZE ( database_name
            / table_or_index_name
            / ( database_name dot table_or_index_name ) )? )

attach_stmt =
  ( ATTACH ( DATABASE )? expr AS database_name )

begin_stmt =
  ( BEGIN ( DEFERRED / IMMEDIATE / EXCLUSIVE )? ( TRANSACTION )? )

commit_stmt =
( ( COMMIT / END ) ( TRANSACTION )? )

rollback_stmt =
( ROLLBACK ( TRANSACTION )? ( TO ( SAVEPOINT )? savepoint_name )? )

savepoint_stmt =
( SAVEPOINT savepoint_name )

release_stmt =
( RELEASE ( SAVEPOINT )? savepoint_name )

create_index_stmt =
( ( CREATE ( UNIQUE )? INDEX ( IF NOT EXISTS )? ) ( ( database_name dot )? index_name ON table_name lparen ( indexed_column comma )+ rparen ) )

indexed_column =
  ( column_name ( COLLATE collation_name )? ( ASC / DESC )? )

create_table_stmt =
  ( CREATE ( TEMP / TEMPORARY )? TABLE ( IF NOT EXISTS )? )
  ( table_ref
    ( lparen ( column_def comma )+ ( comma table_constraint )+ rparen )
    ( AS select_stmt ) )

column_def =
  ( column_name ( type_name )? ( column_constraint )+ )

type_name =
  ( name )+
  ( ( lparen signed_number rparen )
  / ( lparen signed_number comma signed_number rparen ) )?

column_constraint =
  ( ( CONSTRAINT name )?
    ( ( PRIMARY KEY ( ASC / DESC )? conflict_clause ( AUTOINCREMENT )? )
    / ( NOT NULL conflict_clause )
    / ( UNIQUE conflict_clause )
    / ( CHECK lparen expr rparen )
    / ( DEFAULT ( signed_number / literal_value / ( lparen expr rparen ) ) )
    / ( COLLATE collation_name )
    / foreign_key_clause ) )

signed_number =
  ( ( plus / minus )? numeric_literal )

table_constraint =
( ( CONSTRAINT name )? ( ( ( ( PRIMARY KEY ) / UNIQUE ) lparen ( indexed_column comma )+ rparen conflict_clause ) / ( CHECK lparen expr rparen ) / ( FOREIGN KEY lparen ( column_name comma )+ rparen foreign_key_clause ) ) )

foreign_key_clause =
  ( ( REFERENCES foreign_table ( lparen ( column_name comma )+ rparen )? )
    ( ( ( ON ( DELETE / UPDATE )
             ( ( SET NULL )
             / ( SET DEFAULT )
             / CASCADE
             / RESTRICT
             / ( NO ACTION ) ) )
         / ( MATCH name ) )+ )?
    ( ( NOT )? DEFERRABLE ( ( INITIALLY DEFERRED ) / ( INITIALLY IMMEDIATE ) )? )? )

conflict_clause =
( ( ON CONFLICT ( ROLLBACK / ABORT / FAIL / IGNORE / REPLACE ) ) )?

create_trigger_stmt =
  ( ( CREATE ( TEMP / TEMPORARY )? TRIGGER ( IF NOT EXISTS )? )
    ( ( database_name dot )? trigger_name ( BEFORE / AFTER / ( INSTEAD OF ) )? )
    ( ( DELETE
      / INSERT
      / ( UPDATE ( OF ( column_name comma )+ )? ) ) ON table_name )
    ( ( FOR EACH ROW )? ( WHEN expr )? )
    ( BEGIN ( ( update_stmt
              / insert_stmt
              / delete_stmt
              / select_stmt ) semicolon )+ END ) )

create_view_stmt =
  ( ( CREATE ( TEMP / TEMPORARY )? VIEW ( IF NOT EXISTS )? )
    ( ( database_name dot )? view_name AS select_stmt ) )

create_virtual_table_stmt =
  ( ( CREATE VIRTUAL TABLE table_ref )
    ( USING module_name ( lparen ( module_argument comma )+ rparen )? ) )

delete_stmt =
  ( DELETE FROM qualified_table_name ( WHERE expr )? )

delete_stmt_limited =
  ( DELETE FROM qualified_table_name ( WHERE expr )?
    ( ( ( ORDER BY ( ordering_term comma )+ )?
        ( LIMIT expr ( ( OFFSET / comma ) expr )? ) ) )? )

detach_stmt =
( DETACH ( DATABASE )? database_name )

drop_index_stmt =
( DROP INDEX ( IF EXISTS )? ( database_name dot )? index_name )

drop_table_stmt =
  ( DROP TABLE ( IF EXISTS )? table_ref )

drop_trigger_stmt =
( DROP TRIGGER ( IF EXISTS )? ( database_name dot )? trigger_name )

drop_view_stmt =
( DROP VIEW ( IF EXISTS )? ( database_name dot )? view_name )

value =
  v: ( whitespace
       ( ( x: literal_value
           { return { literal: x } } )
       / ( b: bind_parameter
           { return { bind: b } } )
       / ( t: ( table_name dot column_name )
           { return { column: t[2], table: t[1] } } )
       / ( c: column_name
           { return { column: c } } )
       / ( unary_operator expr )
       / call_function
       / ( whitespace lparen expr whitespace rparen )
       / ( CAST lparen expr AS type_name rparen )
       / ( ( NOT ? EXISTS )? lparen select_stmt rparen )
       / ( CASE expr ? ( WHEN expr THEN expr )+ ( ELSE expr )? END )
       / raise_function ) )
  { return v[1] }

expr =
  e: ( whitespace
       ( ( value binary_operator expr )
       / ( value COLLATE collation_name )
       / ( value NOT ? ( LIKE / GLOB / REGEXP / MATCH ) expr ( ESCAPE expr )? )
       / ( value ( ISNULL / NOTNULL / ( NOT NULL ) ) )
       / ( value IS NOT ? expr )
       / ( value NOT ? BETWEEN expr AND expr )
       / ( value NOT ? IN ( ( lparen ( select_stmt / ( expr comma )+ )? rparen )
                          / table_ref ) )
       / value ) )
  { return e[1]; }


call_function =
  ( function_name
    whitespace lparen
               ( ( DISTINCT ? ( expr (whitespace comma expr)* )+ )
               / whitespace star )?
    whitespace rparen )

raise_function =
( RAISE lparen ( IGNORE / ( ( ROLLBACK / ABORT / FAIL ) comma error_message ) ) rparen )

literal_value =
  ( numeric_literal / string_literal / blob_literal
  / NULL / CURRENT_TIME / CURRENT_DATE / CURRENT_TIMESTAMP )

numeric_literal =
  digits:( ( ( ( digit )+ ( decimal_point ( digit )+ )? )
           / ( decimal_point ( digit )+ ) )
           ( E ( plus / minus )? ( digit )+ )? )
  { var x = flatstr(digits);
    if (x.indexOf('.') >= 0) {
      return parseFloat(x);
    }
    return parseInt(x);
  }

insert_stmt =
  ( ( ( INSERT ( OR ( ROLLBACK / ABORT / REPLACE / FAIL / IGNORE ) )? )
      / REPLACE )
    INTO
    table_ref
    ( ( ( lparen ( column_name ( comma column_name )* ) rparen )?
        ( ( VALUES lparen ( expr comma )+ rparen )
          / select_stmt ) )
      / ( DEFAULT VALUES ) ) )

pragma_stmt =
  ( PRAGMA ( database_name dot )? pragma_name
    ( ( equal pragma_value ) / ( lparen pragma_value rparen ) )? )

pragma_value =
( signed_number / name / string_literal )

reindex_stmt =
  ( REINDEX collation_name ( table_ref index_name ) )

select_stmt =
  ( select_cores: ( select_core
                    ( sc: ( compound_operator select_core )*
                          { var acc = [];
                            for (var i = 0; i < sc.length; i++) {
                              acc[i] = merge(sc[i][0], sc[i][1]);
                            }
                            return acc;
                          } ) )
    order_by: ( ( ORDER BY ordering_term ( whitespace comma ordering_term )* )? )
    limit: ( ( LIMIT expr ( ( OFFSET / comma ) expr )? )? ) )
  { var res = { stmt: "select",
                select_cores: flatten(select_cores, true) };
    res = put_if_not_null(res, "order_by", nonempty(order_by));
    res = put_if_not_null(res, "limit", nonempty(limit));
    return res;
  }

select_core =
  ( SELECT d: ( ( DISTINCT / ALL )? )
           c: ( select_result
                ( cx: ( whitespace comma select_result )*
                      { var acc = [];
                        for (var i = 0; i < cx.length; i++) {
                          acc[i] = cx[i][2];
                        }
                        return acc;
                      } ) )
    f: ( j: ( ( FROM join_source )? )
         { return j ? j[1] : [] } )
    w: ( e: ( ( WHERE expr )? )
         { return e ? e[1] : [] } )
    g: ( GROUP BY ( ordering_term comma )+ ( HAVING expr )? )? )
  { c[1].unshift(c[0]);
    var res = { results: c[1] };
    res = put_if_not_null(res, "distinct", nonempty(flatstr(d)));
    res = put_if_not_null(res, "from", nonempty(f));
    res = put_if_not_null(res, "where", nonempty(w));
    res = put_if_not_null(res, "group_by", nonempty(g));
    return res;
  }

select_result =
  r: ( whitespace
       ( ( c: ( column_ref ( a: ( AS whitespace column_alias )
                             { return { alias: a[2] } } )? )
              { return merge(c[1], c[0]) } )
       / ( c: ( table_name dot star )
              { return { table: c[0],
                         column: '*' } } )
       / ( star
           { return { column: '*' } } ) ) )
  { return r[1] }

join_source =
  s: ( whitespace single_source
       ( join_op whitespace single_source join_constraint )* )
  { var acc = [s[1]];
    var rest = s[2];
    for (var i = 0; rest != null && i < rest.length; i++) {
      acc[acc.length] = merge(merge(rest[i][0], rest[i][2]), rest[i][3]);
    }
    return acc;
  }

single_source =
  ( ( x: ( database_name dot table_name AS whitespace1 table_alias )
      { return { database: x[0], table: x[2], alias: x[5] } } )
  / ( x: ( database_name dot table_name )
      { return { database: x[0], table: x[2] } } )
  / ( x: ( table_name AS whitespace1 table_alias )
      { return { table: x[0], alias: x[3] } } )
  / ( x: table_name
      { return { table: x } } )
  / ( s: ( ( t: ( table_ref ( a: ( AS whitespace1 table_alias )
                              { return { alias: a[2] } } )? )
             { return merge(t[1], t[0]) } )
           ( ( idx: ( INDEXED BY whitespace index_name )
               { return { indexed_by: idx[3] } } )
           / ( ( NOT INDEXED )
               { return { indexed_by: null } } ) )? )
      { return merge(s[1], s[0]) } )
  / ( p: ( lparen select_stmt rparen
           ( a: ( AS whitespace table_alias )
             { return { alias: a[2] } } )? )
      { return merge(p[3], p[1]) } )
  / ( j: ( lparen join_source rparen )
      { return j[1] } )
  )

join_op =
  r: ( ( ( ( whitespace comma )
           { return "JOIN" } )
       / ( j: ( NATURAL ?
                ( ( LEFT ( OUTER )? )
                  / INNER
                  / CROSS )?
                JOIN )
           { return flatstr(j) } ) ) )
  { return { join_op: r } }

join_constraint =
  r: ( ( ( ON expr )
       / ( USING
           whitespace lparen
           ( whitespace column_name ( whitespace comma whitespace column_name )* )
           whitespace rparen ) )? )
  { return { join_constraint: nonempty(r) } }

ordering_term =
  ( whitespace
    ( expr ( COLLATE collation_name )? ( ASC / DESC )? ) )

compound_operator =
  o: ( ( UNION ALL ? )
     / INTERSECT
     / EXCEPT )
  { return { compound_operator: flatstr(o) } }

update_stmt =
  ( ( UPDATE ( OR ( ROLLBACK
                  / ABORT
                  / REPLACE
                  / FAIL
                  / IGNORE ) )? qualified_table_name )
    ( SET ( ( column_name equal expr ) comma )+ ( WHERE expr )? ) )

update_stmt_limited =
  ( ( UPDATE ( OR ( ROLLBACK
                  / ABORT
                  / REPLACE
                  / FAIL
                  / IGNORE ) )? qualified_table_name )
    ( SET ( ( column_name equal expr ) comma )+ ( WHERE expr )? )
    ( ( ( ORDER BY ( ordering_term comma )+ )?
        ( LIMIT expr ( ( OFFSET / comma ) expr )? ) ) )? )

qualified_table_name =
  ( table_ref ( ( INDEXED BY index_name ) / ( NOT INDEXED ) )? )

table_ref =
  r: ( ( d: ( database_name dot )
         { return { database: d[0] } } )?
       ( x: table_name
         { return { table: x } } ) )
  { return merge(r[1], r[0]) }

column_ref =
  r: ( ( t: ( table_name dot )
         { return { table: t[0] } } )?
       ( x: column_name
         { return { column: x } } ) )
  { return merge(r[1], r[0]) }

vacuum_stmt =
VACUUM

comment_syntax =
  ( ( minusminus ( anything_except_newline )+ ( newline / end_of_input ) )
  / ( comment_beg ( anything_except_comment_end )+ ( comment_end / end_of_input ) ) )

dot = '.'
comma = ','
semicolon = ';'
minusminus = '--'
minus = '-'
plus = '+'
lparen = '('
rparen = ')'
star = '*'
newline = '\n'
anything_except_newline = [^\n]*
comment_beg = '/*'
comment_end = '*/'
anything_except_comment_end = .* & '*/'
string_literal = '"' (escape_char / [^"])* '"'
escape_char = '\\' .
nil = ''

whitespace =
  [ \t\n\r]*
whitespace1 =
  [ \t\n\r]+

unary_operator =
  x: ( whitespace
       ( '-' / '+' / '~' / 'NOT') )
  { return x[1] }

binary_operator =
  x: ( whitespace
       ('||'
        / '*' / '/' / '%'
        / '+' / '-'
        / '<<' / '>>' / '&' / '|'
        / '<=' / '>='
        / '<' / '>'
        / '=' / '==' / '!=' / '<>'
        / 'IS' / 'IS NOT' / 'IN' / 'LIKE' / 'GLOB' / 'MATCH' / 'REGEXP'
        / 'AND'
        / 'OR') )
  { return x[1] }

digit = [0-9]
decimal_point = dot
equal = '='

name =
  str:[A-Za-z0-9_]+
  { return str.join('') }

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
bind_parameter =
  '?' name
function_name = name
pragma_name = name

error_message = string_literal

CURRENT_TIME = 'now'
CURRENT_DATE = 'now'
CURRENT_TIMESTAMP = 'now'

blob_literal = string_literal

end_of_input = ''

ABORT = whitespace1 "ABORT"
ACTION = whitespace1 "ACTION"
ADD = whitespace1 "ADD"
AFTER = whitespace1 "AFTER"
ALL = whitespace1 "ALL"
ALTER = whitespace1 "ALTER"
ANALYZE = whitespace1 "ANALYZE"
AND = whitespace1 "AND"
AS = whitespace1 "AS"
ASC = whitespace1 "ASC"
ATTACH = whitespace1 "ATTACH"
AUTOINCREMENT = whitespace1 "AUTOINCREMENT"
BEFORE = whitespace1 "BEFORE"
BEGIN = whitespace1 "BEGIN"
BETWEEN = whitespace1 "BETWEEN"
BY = whitespace1 "BY"
CASCADE = whitespace1 "CASCADE"
CASE = whitespace1 "CASE"
CAST = whitespace1 "CAST"
CHECK = whitespace1 "CHECK"
COLLATE = whitespace1 "COLLATE"
COLUMN = whitespace1 "COLUMN"
COMMIT = whitespace1 "COMMIT"
CONFLICT = whitespace1 "CONFLICT"
CONSTRAINT = whitespace1 "CONSTRAINT"
CREATE =
  whitespace "CREATE"
CROSS = whitespace1 "CROSS"
DATABASE = whitespace1 "DATABASE"
DEFAULT = whitespace1 "DEFAULT"
DEFERRABLE = whitespace1 "DEFERRABLE"
DEFERRED = whitespace1 "DEFERRED"
DELETE =
  whitespace "DELETE"
DESC = whitespace1 "DESC"
DETACH = whitespace1 "DETACH"
DISTINCT = whitespace1 "DISTINCT"
DROP = whitespace1 "DROP"
E =
  "E"
EACH = whitespace1 "EACH"
ELSE = whitespace1 "ELSE"
END = whitespace1 "END"
ESCAPE = whitespace1 "ESCAPE"
EXCEPT = whitespace1 "EXCEPT"
EXCLUSIVE = whitespace1 "EXCLUSIVE"
EXISTS = whitespace1 "EXISTS"
EXPLAIN =
  whitespace "EXPLAIN"
FAIL = whitespace1 "FAIL"
FOR = whitespace1 "FOR"
FOREIGN = whitespace1 "FOREIGN"
FROM = whitespace1 "FROM"
GLOB = whitespace1 "GLOB"
GROUP = whitespace1 "GROUP"
HAVING = whitespace1 "HAVING"
IF = whitespace1 "IF"
IGNORE = whitespace1 "IGNORE"
IMMEDIATE = whitespace1 "IMMEDIATE"
IN = whitespace1 "IN"
INDEX = whitespace1 "INDEX"
INDEXED = whitespace1 "INDEXED"
INITIALLY = whitespace1 "INITIALLY"
INNER = whitespace1 "INNER"
INSERT =
  whitespace "INSERT"
INSTEAD = whitespace1 "INSTEAD"
INTERSECT = whitespace1 "INTERSECT"
INTO = whitespace1 "INTO"
IS = whitespace1 "IS"
ISNULL = whitespace1 "ISNULL"
JOIN = whitespace1 "JOIN"
KEY = whitespace1 "KEY"
LEFT = whitespace1 "LEFT"
LIKE = whitespace1 "LIKE"
LIMIT = whitespace1 "LIMIT"
MATCH = whitespace1 "MATCH"
NATURAL = whitespace1 "NATURAL"
NO = whitespace1 "NO"
NOT = whitespace1 "NOT"
NOTNULL = whitespace1 "NOTNULL"
NULL = whitespace1 "NULL"
OF = whitespace1 "OF"
OFFSET = whitespace1 "OFFSET"
ON = whitespace1 "ON"
OR = whitespace1 "OR"
ORDER = whitespace1 "ORDER"
OUTER = whitespace1 "OUTER"
PLAN = whitespace1 "PLAN"
PRAGMA = whitespace1 "PRAGMA"
PRIMARY = whitespace1 "PRIMARY"
QUERY = whitespace1 "QUERY"
RAISE = whitespace1 "RAISE"
REFERENCES = whitespace1 "REFERENCES"
REGEXP = whitespace1 "REGEXP"
REINDEX = whitespace1 "REINDEX"
RELEASE = whitespace1 "RELEASE"
RENAME = whitespace1 "RENAME"
REPLACE =
  whitespace "REPLACE"
RESTRICT = whitespace1 "RESTRICT"
ROLLBACK = whitespace1 "ROLLBACK"
ROW = whitespace1 "ROW"
SAVEPOINT = whitespace1 "SAVEPOINT"
SELECT =
  whitespace "SELECT"
SET = whitespace1 "SET"
TABLE = whitespace1 "TABLE"
TEMP = whitespace1 "TEMP"
TEMPORARY = whitespace1 "TEMPORARY"
THEN = whitespace1 "THEN"
TO = whitespace1 "TO"
TRANSACTION = whitespace1 "TRANSACTION"
TRIGGER = whitespace1 "TRIGGER"
UNION = whitespace1 "UNION"
UNIQUE = whitespace1 "UNIQUE"
UPDATE =
  whitespace "UPDATE"
USING = whitespace1 "USING"
VACUUM = whitespace1 "VACUUM"
VALUES = whitespace1 "VALUES"
VIEW = whitespace1 "VIEW"
VIRTUAL = whitespace1 "VIRTUAL"
WHEN = whitespace1 "WHEN"
WHERE = whitespace1 "WHERE"
