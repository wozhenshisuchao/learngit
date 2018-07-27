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

#pan duan yi xia xi tong ba ben,jue ding shi fou zhi xing geng gai wang ka pei zhi cao zuo.
#ju ti gong neng ru xia:
#1.geng gai ming ling ti shi fu yan se 6 red 7 lv se.
#2.she zhe bie ming.
#3.guan bi fang huo qiang.
#4.guan bi selinux.
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
sed -i.bak '/User/aalias cdnet="cd /etc/sysconfig/network-scripts"' ~/.bashrc && . ~/.bashrc
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux && setenforce 0
cat > /etc/yum.repos.d/media.repo <<end
[media]
name=Media
baseurl=file:///media/
gpgcheck=0
end
echo -e "\e[1;32myum file yi chuang jian!\e[0m"
version=`egrep -ow '[0-9]+' /etc/redhat-release |head -n1`
if [ $version == 6 ];then
	echo 'PS1="\[\e[1;31m\][\u@\h \w]\\$ \[\e[0m\]"' > /etc/profile.d/env.sh && . /etc/profile.d/env.sh
	service iptables stop
	chkconfig iptables off

	exit 0
else
	
	echo 'PS1="\[\e[1;32m\][\u@\h \w]\\$ \[\e[0m\]"' > /etc/profile.d/env.sh && source /etc/profile.d/env.sh
	systemctl stop firewalld.service
	systemctl disable firewalld.service &> /dev/null

	read -p "shi fou geng gai centos7 de wang ka name?(yes\no)" Yesorno
	while [[ ! $Yesorno =~  ^([Yy]|[Yy][Ee][Ss])$ ]] && [[ ! $Yesorno =~  ^([Nn]|[Nn][Oo])$ ]]; do
		echo "Please in put yes or no."
		read -p "shi fou geng gai centos7 de wang ka name?\n" Yesorno
	done
	if [[ $Yesorno =~  ^([Yy]|[Yy][Ee][Ss])$ ]] ;then
		ls /etc/sysconfig/network-scripts/ |grep "ifcfg" |grep -v "ifcfg-lo" |tr "\n" " " > /tmp/name && read a b c d e f g h i j </tmp/name
		old_file=/etc/sysconfig/network-scripts/
		new_file=/etc/sysconfig/network-scripts/ifcfg-eth
		GRUB_FILE=/etc/default/grub
		[ ! -f "$old_file$a" ] && echo "PeiZhi_File is BuCunZai,Error!!" > /dev/stderr && exit 1
		[ -e "$new_file"0 ] && echo "File YiCunZai,Error!!" > /dev/stderr && exit 1
		[ ! -w "$GRUB_FILE" ] && echo "$GRUB_FILE BuCunZai,Error!!" > /dev/stderr && exit 1
		[ -z $a ] && echo "$a BuCunZai,Error!!" > /dev/stderr || { sed -i -e 's/NAME=.*/NAME=eth0/' -e 's/DEVICE.*/DEVICE=eth0/' $old_file$a && mv $old_file$a "$new_file"0; }
		[ -z $b ] || { sed -i -e 's/NAME=.*/NAME=eth1/' -e 's/DEVICE.*/DEVICE=eth1/' $old_file$b && mv $old_file$b "$new_file"1; } 
		[ -z $c ] || { sed -i -e 's/NAME=.*/NAME=eth2/' -e 's/DEVICE.*/DEVICE=eth2/' $old_file$c && mv $old_file$c "$new_file"2; }
		[ -z $d ] || { sed -i -e 's/NAME=.*/NAME=eth3/' -e 's/DEVICE.*/DEVICE=eth3/' $old_file$d && mv $old_file$d "$new_file"3; }
		[ -z $e ] || { sed -i -e 's/NAME=.*/NAME=eth4/' -e 's/DEVICE.*/DEVICE=eth4/' $old_file$e && mv $old_file$e "$new_file"4; }
		[ -z $f ] || { sed -i -e 's/NAME=.*/NAME=eth5/' -e 's/DEVICE.*/DEVICE=eth5/' $old_file$f && mv $old_file$f "$new_file"5; }
		[ -z $g ] || { sed -i -e 's/NAME=.*/NAME=eth6/' -e 's/DEVICE.*/DEVICE=eth6/' $old_file$g && mv $old_file$g "$new_file"6; }
		[ -z $h ] || { sed -i -e 's/NAME=.*/NAME=eth7/' -e 's/DEVICE.*/DEVICE=eth7/' $old_file$h && mv $old_file$h "$new_file"7; }
		[ -z $i ] || { sed -i -e 's/NAME=.*/NAME=eth8/' -e 's/DEVICE.*/DEVICE=eth8/' $old_file$i && mv $old_file$i "$new_file"8; }
		[ -z $j ] || { sed -i -e 's/NAME=.*/NAME=eth9/' -e 's/DEVICE.*/DEVICE=eth9/' $old_file$j && mv $old_file$j "$new_file"9; }
		sed -i.bak '/GRUB_CMDLINE_LINUX/s@rhgb quiet"@"net.ifnames=0 biosdevname=0" rhgb quiet"@' $GRUB_FILE
		grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null
		reboot

	else
		exit 0
	fi

fi
