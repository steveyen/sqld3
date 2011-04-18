SQL parser in JavaScript
========================

This project provides a PEG.js grammar for SQL syntax. Why? I wanted
to properly parse SQL in JavaScript, knocking down yet another thing
in that long list of things that will be reimplemented in JavaScript
one day.

See the ./sql.pegjs file, or...

* http://github.com/steveyen/sqld3/blob/master/sql.pegjs

Unlike previous hand-coded attempts at SQL parsing in JavaScript, such
as my previous http://code.google.com/p/trimpath/wiki/TrimQuery, the
parsing here is grammar (PEG) based.

SQL syntax
----------

The SQL syntax follows sqlite 3.7 documented syntax, specifically from...

* sqlite's art/syntax/bubble-generator-data.tcl
* http://www.sqlite.org/docsrc/artifact?name=a7001f134e2f341c3b46fad9623556260530904b

See also
--------

* PEG.js: http://pegjs.majda.cz/
* sqlite: http://www.sqlite.org

License
-------

Apache 2.0 -- this was made for you and me.

