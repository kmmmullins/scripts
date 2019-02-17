
linenum=0;

for n in `cat /home/confab/archive/allspaces-stellar-unix.txt`
do

echo "$n" 
linenum=`expr $linenum + 1`
echo $linenum;

kmyn=`grep $n /home/confab/logs/access.*.log |wc -l` 
echo "$kmyn"

if `expr $kmyn > 0 `
then
echo "***********************************************" 
echo " $linenum  --- Found $n in use .... $kmyn .... " 
echo "***********************************************" 
echo "$n .. $kmyn "  >> /home/confab/archive/wikispace-inuse.log
else
echo " no .................................."
echo " $n $linenum  --- NOTTTTT - Found ........ " 
echo " no .................................."
echo "$n -- $kmyn" >> /home/confab/archive/wikispaces-todelete.log
fi
done

