

read -p "Do you want to change IP's (yes or no)" choice
case "$choice" in
	 Yes|YES|yes|y) echo "Yes, Change the IPs";;
	 No|NO|no|n)    echo "No, do not change the IPs";;
	 *) echo "Bad choice" ;;
esac
