
    if [ -z $1 ]
       then
          if [ -f /sys/hypervisor/uuid ] && [ `head -c 3 /sys/hypervisor/uuid` == ec2 ]; then
              AWS="yes"
	      echo " "
              echo "You did not define an IP address to use for this installation."
              echo "This instance is running on AWS which requires the external address defined."
              echo "Without defining a external IP address the script will use the private IP address"
              echo "which will not be accessable via the internet"
              echo " "
              echo "Please exit and run again with the IP as a 
	     
	     
	      variable via: export IP=externalIPaddress" 
	      echo " $AWS"
          else
              AWS="no"
	      IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
	      echo " "
              echo "You did not define and IP address to use for this installation."
              echo "This instance will use the current interal address  which is"
              echo "  ....  $IP  ...."
              echo " "
              echo "If this IP address is incorrect, Please Exit and define an IP variable via: export IP=externalIPaddres"
	      echo " $AWS"
          fi 

        read -p "Do you want to EXIT and define an IP variable  (yes or no)" choice
        case "$choice" in
           Yes|YES|yes|y) echo "Yes I want to EXIT"
	     echo " "
	     echo "Exiting "
	     echo " "
           exit  ;;
	   No|NO|no|n)    echo "OK continuing with installation";;
	   *) echo "Bad choice - Try again" ;;
        esac
   else
#       IP=$1
       echo "Using given IP: $1"
    echo "The IP variable is $IP"
   fi
else 
   echo "ok ip is ... $IP"
    echo "The IP variable is $IP"
   echo "last else" 
fi
