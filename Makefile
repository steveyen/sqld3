all:
	./sql-bubble.rb > tmp/rules.rb
	./bubble-to-pegjs.rb tmp/rules.rb > tmp/sql.pegjs
