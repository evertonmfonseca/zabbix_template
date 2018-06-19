#!/bin/sh

# @Programa 
# 	@name: zbp.pf.sh
#	@versao: 0.1
#	@Data 22 de Abril de 2016
#	@Copyright: 
#		2MTI Tecnologia e Serviços, 2016 - www.2mti.com.br
#		Pillares Consulting, 2016 - www.pillares.net
# --------------------------------------------------------------------------
# LICENSE
#
# zbp.pf.sh is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# zbp.pf.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------------

scriptName=zbp.pf.sh

dialog --msgbox 'This script install zabbix-proxy3 in your Pfsense 2.2 and 2.3 series.\n\nDevelopers:\n Halexsandro Sales <halexsandro@gmail.com>\n Marcos Farias <mcassiojr@gmail.com>\n\nCopyright: 2MTI and Pillares\n\nLicence: GPL v.3' 15 60 --title '$scriptName'

dialog --inputbox 'Input the Zabbix Server address...' 0 0 2> /tmp/var.txt

serverName=$(cat /tmp/var.txt)

dialog --inputbox 'Input the Zabbix Proxy name in here...' 0 0 2> /tmp/var.txt

proxyName=$(cat /tmp/var.txt)

clear

echo "Updating and resolving dependences..."

pkg update 
pkg upgrade
pkg install sqlite3 perl5 indexinfo nettle gmp ca_root_nss gettext-runtime libffi  libidn mysql56-client zabbix22-agent net-snmp libiconv
 
cd / 

clear 

fetch http://pillares.net/scripts/pfZabbix3.tgz

tar -zxvf pfZabbix3.tgz

rm /pfZabbix3.tgz

cd /tmp 

arq=`uname -m`

mv /usr/local/src/zabbix/sbin/zabbix_proxy_$arq /usr/local/src/zabbix/sbin/zabbix_proxy
rm /usr/local/src/zabbix/sbin/zabbix_proxy_*

chmod 775 /usr/local/etc/rc.d/zabbix_proxy.sh
chmod +x /usr/local/src/zabbix/sbin/zabbix_proxy

echo "ProxyMode=0" > /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "Server=$serverName" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "Hostname=$proxyName" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "LogFile=/tmp/zabbix_proxy.log" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "LogFileSize=0" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "PidFile=/tmp/zabbix_proxy.pid" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "DBName=/var/lib/sqlite/zabbix.db" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "DBUser=zabbix" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "ProxyOfflineBuffer=1" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "HeartbeatFrequency=10" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "ConfigFrequency=20" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "DataSenderFrequency=2" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "StartPollers=25" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "StartPingers=10" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "StartDiscoverers=10" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "Timeout=3" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "ExternalScripts=/usr/lib/zabbix/externalscripts" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "FpingLocation=/usr/bin/fping" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf
echo "LogSlowQueries=3000" >> /usr/local/src/zabbix/etc/zabbix_proxy.conf

chown -R zabbix:zabbix /var/lib/sqlite

echo "zabbix_proxy=\"YES\"" >> /etc/rc.conf

/usr/local/src/zabbix/sbin/zabbix_proxy

dialog --msgbox 'The process is finish,\n\nIf you need change the conf of proxy, the files are in /usr/local/src\nHave you a nice day!!!' 20 60 --title '$scriptName'

clear

