


for x in ec2-user@52.91.118.56  ec2-user@52.201.221.251 root@184.73.215.50 ec2-user@107.20.249.75 
do
     ssh  -i /home/kmullins/secret/i2b2key.pem $x "uname -a && df -h & top -b | head -n 5  "
    echo "   "

done     
     
