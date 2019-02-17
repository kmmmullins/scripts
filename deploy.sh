#!/bin/bash
# Alexsey
cpu_num=1

function help { 
echo Invalid Option: -$OPTARG. Usage: "$0"  -i 'inventory file' -c 'number of cpus' -m 'mem_size' -d 'dipr', -d -c -m optional 1>&2 ; 
exit 2
} 

if [[ ! $@ =~ ^\-.+ ]]
then
  help
fi

while getopts ":i:c:d:m:" opt
   do
     case ${opt} in
        i ) inventory=$OPTARG;;
        c ) cpu=$OPTARG;;
        d ) dns_name=$OPTARG;;
        m ) mem=$OPTARG;;
       \? | h  )
           help
           exit 2
           ;;
     esac
done
target="vars.yml"
echo >  $target
echo $mem
echo "test mem mult"
let "a = $mem * 1024"
echo $a

echo --- > $target
echo "spec:" >> $target
echo "  nodes:" >> $target
for i in `cat $inventory`; do 
   echo "  - name: $i" >> $target
   if  [[ -z  $cpu  ]]; then
      echo "    cpu: 1" >> $target
   else 
      echo "    cpu: $cpu" >> $target
   fi
   if  [[ -z  $mem ]]; then
      echo "    mem: 2048" >> $target
   else
      a=$( expr 1024 '*' "$mem" )
      echo "    mem: $a" >> $target
   fi

done
cat $target

  if [ -z $dns_name ]; then 
    ansible-playbook --vault-id  @prompt -i $inventory deploy_dev01.yml
  else
    ansible-playbook --vault-id  @prompt -i $inventory deploy_dev01.yml -e dns_name=$dns_name
  fi

