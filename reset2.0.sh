#!/bin/bash
#
#********************************************************************
#Author:		su_chao
#QQ: 			bugei
#Date: 			2018-04-11
#FileName：		reset.sh
#URL: 			www.178linux.com/user/su_chao
#Description：		The test script
#Copyright (C): 	2018 All rights reserved
#********************************************************************

#pan duan yi xia xi tong ban ben,jue ding shi fou zhi xing geng gai wang ka pei zhi cao zuo.
#ju ti gong neng ru xia:
#1.geng gai ming ling ti shi fu yan se 6 red 7 lv se.
#2.she zhi bie ming.
#3.stop iptables/firewall
#4.stop selinux.
#5.tian jia ben di yum mu ban.
#6.geng gai 7 de wang ka ming cheng wei"eth"xi lie,fang bian tong yi guan li.
#kao lv dao guang pan bu yi ding lian jie,suo yi mei you gua zai guan pan,xu yao shou dong gua zai.
sed -i.bak -e '/^PASS_MIN_LEN/s/[0-9]/10/' -e '/PASS_MIN_DAYS/s/[0-9]/7/' /etc/login.defs
sed -i.bak 's@/dev/tty\[1-6\]@/dev/tty[1-2]@' /etc/sysconfig/init
sed -i.bak -e 's/^/#/' -e '/#tty[1-2]/s/#//' /etc/securetty
chmod +x /etc/securetty
/etc/securetty reload &> /dev/null
sed -i.bak '/required/s/#//' /etc/pam.d/su
[ -f /root/.profile ] && chmod 751 /root/.profile
[ -f /root/.bash_profile ] && chmod 751 /root/.bash_profile
chmod 751 /root/
sed -i.bak '/User/aalias cdyum="cd /etc/yum.repos.d/"' ~/.bashrc
sed -i '/User/aalias renet="/etc/init.d/network restart"' ~/.bashrc
sed -i '/User/aalias cdnet="cd /etc/sysconfig/network-scripts"' ~/.bashrc && source /root/.bashrc
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux && setenforce 0
mkdir /etc/yum.repos.d/backup
mv /etc/yum.repos.d/* /etc/yum.repos.d/backup &>/dev/null
cat > /etc/yum.repos.d/media.repo <<end
[media]
name=Media
baseurl=file:///media/
gpgcheck=0

[epel]
name=epel
baseurl=https://mirrors.aliyun.com/epel/$releasever/x86_64/
gpgcheck=0
end
echo -e "\e[1;32myum file yi chuang jian!\e[0m"
version=`egrep -ow '[0-9]+' /etc/redhat-release |head -n1`
if [ $version == 6 ];then
	echo 'PS1="\[\e[1;31m\][\u@\h \w]\\$ \[\e[0m\]"' > /etc/profile.d/env.sh && source /etc/profile.d/env.sh
	service iptables stop
	chkconfig iptables off

	exit 0
else
	
	echo 'PS1="\[\e[1;33m\][\u@\h \w]\\$ \[\e[0m\]"' > /etc/profile.d/env.sh && source /etc/profile.d/env.sh
	systemctl stop firewalld.service
	systemctl disable firewalld.service &> /dev/null

	read -p "shi fou geng gai centos7 de wang ka name?(yes\no)" Yesorno
	while [[ ! $Yesorno =~  ^([Yy]|[Yy][Ee][Ss])$ ]] && [[ ! $Yesorno =~  ^([Nn]|[Nn][Oo])$ ]]; do
		echo "\e[1;31mPlease in put yes or no.\e[0m"
		read -p "shi fou geng gai centos7 de wang ka name?" Yesorno
	done
	if [[ $Yesorno =~  ^([Yy]|[Yy][Ee][Ss])$ ]] ;then
		GRUB_FILE=/etc/default/grub
		old_file=/etc/sysconfig/network-scripts/
		ls /etc/sysconfig/network-scripts/ifcfg-* |grep "ifcfg" |grep -v "ifcfg-lo" > tmpfile
        b=0
		for i in `cat tmpfile`;do
  			 new_file=/etc/sysconfig/network-scripts/ifcfg-eth$b
  			 new_name=eth$b
     		 sed -i -e "s/NAME=.*/NAME=$new_name/" -e "s/DEVICE.*/DEVICE=$new_name/" $i && mv $i "$new_file"
             let b++
		done
		[ ! -w "$GRUB_FILE" ] && echo "GRUB_FILE BuCunZai,Error!!" > /dev/stderr && exit 3
		sed -i.bak '/GRUB_CMDLINE_LINUX/s@rhgb quiet"@"net.ifnames=0 biosdevname=0" rhgb quiet"@' $GRUB_FILE
		grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null
		echo -e "\e[1;32mrebooting,Don't worry......\e[0m"
		sleep 10
		#[ ! -f "$old_file$i" ] && echo "Old_Config_File is BuCunZai,Error!!" > /dev/stderr && exit 1
		#[ -e "$new_file" ] && echo "New_Config_File YiCunZai,Error!!" > /dev/stderr && exit 2
		rm -f tmpfile
		reboot
	else
		exit 0
	fi
fi
