#!/bin/bash

export PS1='\u:\h> '
alias ksiz='du -sk * | sort -n --'
alias bash='clear;/bin/bash -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias rhtpd='cat httpd.conf | grep -v "#" | more'
alias kset='scp kmullins@adcom-10:/home/kmullins/scripts/kmm_setup.sh .'
alias ls=ls
alias tnet='telnet -axFl root '
alias term='xterm -bg LIGHTCYAN -fg Black &'
alias termw='xterm -bg AntiqueWhite -fg Black &'
alias termgr='xterm -bg LIGHTGREY -fg BLACK &'
alias termcy='xterm -bg CYAN -fg BLACK &'
alias termr='xterm -bg AntiqueWhite -fg DarkRed &'
alias termg='aterm -ls -fg gray -bg white &'
alias xtop='xterm -fn 6x13 -bg LIGHTBLUE -fg black -e top &'
alias xsu='xterm -fn 7x18 -bg LIGHTYELLOW -fg black -e su - &'
alias termbr='xterm -ls -fg white -bg brown &'
alias termb='xterm -ls -fg green -bg black &'
alias gterm='gnome-terminal &'

alias websistail='tail -200 /oracle/logs/websis/student-secure_access_log &'
alias mitsistail='tail -200 /oracle/logs/mitsis/mitsis_access_log &'

alias sisapptail='tail -200 /oracle/logs/j2ee/sisapp-secure_access_log &'
alias stargatetail='tail -200 /oracle/ora_app/prod_app01/Apache/Apache/logs/access_log &'

