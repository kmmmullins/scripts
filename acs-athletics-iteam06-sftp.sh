#!/usr/bin/expect

# 2012-11-28 kmullins@mit.edu

set rmtaccount [lrange $argv 0 0]
set rmtfile [lrange $argv 1 1]
set timeout 120
spawn sftp $rmtaccount
expect " password: "
send "scooter\r"
expect "sftp> "
send "cd SA\r"
expect "sftp> "
send "put $rmtfile\r"
expect "sftp> "
send "quit\r"

