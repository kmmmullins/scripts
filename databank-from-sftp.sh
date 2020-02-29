#!/usr/bin/expect

# 2011-10-27 bknoll@mit.edu

set rmtaccount [lrange $argv 0 0]
set rmtfile [lrange $argv 1 1]
set timeout 500
spawn sftp $rmtaccount
expect " password: "
send "Y1NVUZm6\r"
expect "sftp> "
send "cd outgoing\r"
expect "sftp> "
send "get $rmtfile\r"
expect "sftp> "
send "quit\r"

