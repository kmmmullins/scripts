for ppid in 3495 18621 18623 18626 18628 18630 18631 18633 18658 18659
do
ssh root@earth-app-21 "top -b -n1 | grep www"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
ssh root@earth-app-21 "top -b -n1 | grep $ppid"
echo $ppid $task
done

