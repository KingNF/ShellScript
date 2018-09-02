#!/bin/bash
randpass(){
	#init password,length=8,it is combined by 0-9 numbers and 26 Lower Letters and 26 Upper Letters 
	length=8
	i=1
	seq=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
	num_seq=${#seq[@]}
	while [ "$i" -le "$length" ]
	do
 		seqrand[$i]=${seq[$((RANDOM%num_seq))]}
 		let "i=i+1"
	done
	echo ${seqrand[@]:1:$length}|sed 's/ //g'
}

add(){
	# this function need three parms ,the first param is username ,the second parm is UID ,and the third param is GID
	#$1: username $2 UID $3 GID

	echo "adding user" $1

	# judag if not user account is exists
	egrep "^$1" /etc/passwd >& /dev/null
	if [ $? -eq 0 ]
	then
		sed -i '/^'"$1"'/d' /etc/passwd
		sed -i '/^'"$1"'/d' /etc/shadow
	fi
	echo "$1:x:$2:$3::/home/$1:/bin/bash">>/etc/passwd

	pass=$(randpass)
	#echo $pass | passwd $1 --stdin > /dev/null 2>&1
	seconds=$(date +"%s")
	days=$[$seconds/(24*60*60)]
	md5Pass=$(openssl passwd -1 $pass)
	echo "$1:$md5Pass:$days:0:99999:7:::">>/etc/shadow

	# judag if not user group is exists
	egrep "^$1" /etc/group >& /dev/null
	if [ $? -eq 0 ]
	then
		sed -i '/^'"$1"'/d' /etc/group
		sed -i '/^'"$1"'/d' /etc/gshadow 
	fi
	echo "$1:x:$3:">>/etc/group
	echo "$1:!::">>/etc/gshadow
	
	#judge if not home folder exists the user folder
	if [ -e /home/$1 ]
	then
		rm -rf /home/$1
	fi

	# make the folder of the user home
	mkdir /home/$1
	cp -r /etc/skel/. /home/$1
	chown -R $1:$1 /home/$1
	chmod -R go= /home/$1
	echo "user $1 Created Successed,password is $pass"
}

configIptables(){
	#close all ports
	echo "starting change the iptables rule"
	iptables -P INPUT DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT DROP
	#open 22 port
	iptables -A INPUT -p tcp --dport 22 -j ACCEPT
	iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
	#service iptables save
	iptables-save > /etc/sysconfig/iptables
	echo "The iptables rule save Successed"
}

user_group=(operator admin auditor)
uid=6002
gid=6002
for user in ${user_group[*]}
do
	egrep $uid /etc/passwd >& /dev/null
	if [ $? -ne 0 ]
	then
		egrep $gid /etc/group >& /dev/null
		if [ $? -ne 0 ]
		then	
			add $user $uid $gid
		fi
	fi
	let "uid=uid+1"
	let "gid=gid+1"
done
configIptables
