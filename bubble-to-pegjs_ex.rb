#!/usr/bin/env ruby

$keywords['EXPLAIN'] = true
$keywords['QUERY'] = true
$keywords['PLAN'] = true

$override[:sql_stmt] = <<-EOS
( ( EXPLAIN ( QUERY PLAN )? )? (
//  alter_table_stmt
//  / analyze_stmt
//  / attach_stmt / begin_stmt / commit_stmt
//  / create_index_stmt / create_table_stmt / create_trigger_stmt
//  / create_view_stmt / create_virtual_table_stmt
//  / delete_stmt / delete_stmt_limited
//  / detach_stmt / drop_index_stmt / drop_table_stmt / drop_trigger_stmt / drop_view_stmt
//  / insert_stmt
//  / pragma_stmt / reindex_stmt / release_stmt / rollback_stmt / savepoint_stmt
    select_stmt
//  / update_stmt / update_stmt_limited
//  / vacuum_stmt
) )
EOS
