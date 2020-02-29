server=axplor
USER=ssitacs
pass=qu1ckp4y

ftp -v -n $server <<END_OF_SESSION
user $USER $pass
ls
bye
END_OF_SESSION

