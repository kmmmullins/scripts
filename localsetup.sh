


LLOCAL=/opt/local
LLOCALGIT=/opt/local/git
mkdir $LLOCAL
mkdir $LLOCALGIT

cd $LLOCALGIT

$RUNAS bash << _
git clone https://github.com/kmullins/i2b2-quickstart.git 

ls -la
cd $LLOCAL

ls -la  $LLOCALGIT/i2b2-quickstart/scripts/install/install.sh

download_i2b2_source $LLOCAL
unzip_i2b2core $LLOCAL






