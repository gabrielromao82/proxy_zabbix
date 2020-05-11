####################################
#####################################
############## CRIAR USUARIO ANTES########
##  adduser zabbix --no-create-home
#####################################
#####################################
#####################################
###################################

HOST="br-sp-proxy"
IPSERVER="10.119.100.60"

#Instalar o Python

apt-get -y install build-essential snmp vim libssh2-1-dev libssh2-1 libopenipmi-dev libsnmp-dev wget libcurl4-gnutls-dev fping libxml2 libxml2-dev curl libcurl3-gnutls libcurl3-gnutls-dev libiksemel-dev libiksemel-utils libiksemel3 sqlite3 libsqlite3-dev libevent-dev
apt-get -y install software-properties-common


VERSAO=4.4.0
export VERSAO
cd /tmp
wget http://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/$VERSAO/zabbix-$VERSAO.tar.gz

tar xzvf zabbix-$VERSAO.tar.gz

chmod -R +x zabbix-$VERSAO

cd zabbix-$VERSAO/database/sqlite3/
mkdir /var/lib/sqlite3/
sqlite3 /var/lib/sqlite3/zabbix.db < schema.sql
chown -R zabbix:zabbix /var/lib/sqlite3/

#Agora, vamos compilar o Zabbix Proxy:

cd /tmp/zabbix-$VERSAO

./configure --enable-proxy --enable-agent --with-sqlite3 --with-net-snmp --with-libcurl=/usr/bin/curl-config --with-ssh2 --with-openipmi

make install

#Edite o arquivo /usr/local/etc/zabbix_agentd.conf e configure:

echo -n > /usr/local/etc/zabbix_agentd.conf
echo "PidFile=/tmp/zabbix_agentd.pid" >> /usr/local/etc/zabbix_agentd.conf
echo "LogFile=/tmp/zabbix_agentd.log" >> /usr/local/etc/zabbix_agentd.conf
echo "LogFileSize=2" >> /usr/local/etc/zabbix_agentd.conf
echo "DebugLevel=3" >> /usr/local/etc/zabbix_agentd.conf
echo "Server=$IPSERVER" >> /usr/local/etc/zabbix_agentd.conf
echo "ListenPort=10050" >> /usr/local/etc/zabbix_agentd.conf
echo "Hostname= $HOST" >> /usr/local/etc/zabbix_agentd.conf
echo "Timeout=3" >> /usr/local/etc/zabbix_agentd.conf


#Edite o arquivo /usr/local/etc/zabbix_proxy.conf e configure:

echo -n > /usr/local/etc/zabbix_proxy.conf
echo "ProxyMode=0" >> /usr/local/etc/zabbix_proxy.conf
echo "Server=172.16.0.247" >> /usr/local/etc/zabbix_proxy.conf
echo "Hostname= $HOST" >> /usr/local/etc/zabbix_proxy.conf
echo "LogFile=/tmp/zabbix_proxy.log" >> /usr/local/etc/zabbix_proxy.conf
echo "LogFileSize=2" >> /usr/local/etc/zabbix_proxy.conf
echo "DebugLevel=3" >> /usr/local/etc/zabbix_proxy.conf
echo "PidFile=/tmp/zabbix_proxy.pid" >> /usr/local/etc/zabbix_proxy.conf
echo "DBName=/var/lib/sqlite3/zabbix.db" >> /usr/local/etc/zabbix_proxy.conf
echo "ProxyLocalBuffer=24" >> /usr/local/etc/zabbix_proxy.conf
echo "ProxyOfflineBuffer=24" >> /usr/local/etc/zabbix_proxy.conf
echo "DataSenderFrequency=1" >> /usr/local/etc/zabbix_proxy.conf
echo "StartIPMIPollers=1" >> /usr/local/etc/zabbix_proxy.conf
echo "Timeout=3" >> /usr/local/etc/zabbix_proxy.conf
echo "FpingLocation=/usr/bin/fping" >> /usr/local/etc/zabbix_proxy.conf


cd /etc/init.d/

wget https://raw.githubusercontent.com/Mazuco/zabbix-aptUpdates/master/zabbix_agentd

wget https://raw.githubusercontent.com/Mazuco/zabbix-aptUpdates/master/zabbix_proxy

chmod +x /etc/init.d/zabbix_proxy /etc/init.d/zabbix_agentd

/etc/init.d/zabbix_proxy start
/etc/init.d/zabbix_agentd start
update-rc.d -f zabbix_proxy defaults
update-rc.d -f zabbix_agentd defaults
