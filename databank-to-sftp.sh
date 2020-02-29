#!/usr/bin/expect

set rmtaccount [lrange $argv 0 0]
set rmtfile [lrange $argv 1 1]
set timeout 500
spawn sftp $rmtaccount
expect " password: "
send "Y1NVUZm6\r"
expect "sftp> "
send "cd incoming\r"
expect "sftp> "
send "put $rmtfile\r"
expect "sftp> "
send "quit\r"

