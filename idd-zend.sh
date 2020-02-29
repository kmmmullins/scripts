date
ssh root@sky-app-21 "top -b -n1 | grep load"
ssh root@sky-app-21 "top -b -n1 | grep www"
echo "_______________"
ssh root@sky-app-22 "top -b -n1 | grep load"
ssh root@sky-app-22 "top -b -n1 | grep www"
echo "_______________"

