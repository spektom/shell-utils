#!/bin/sh

if [ "$(id -u)" != "0" ]; then
	echo
	echo "WARNING: You are running this script as a NON root user."
	echo "Some system information may be unavailable!"
fi

tmpdir="sysinfo-$(date +'%Y%m%d-%H%M%S-%Z')"
mkdir $tmpdir || exit $?
cd $tmpdir

PATH=/usr/sbin:/usr/bin:/sbin:/bin

gather() {
	file=$1
	shift
	cmd=$1
	which $cmd >/dev/null 2>&1 && "$@" >>$file 2>&1
}

echo
echo -n "Gathering statistics ..."
gather uname uname -a
gather uptime uptime
gather selinux sestatus
gather dmesg dmesg -T
gather df df -h
gather mount mount
gather fdisk fdisk -lu
gather ps ps faux
gather sysctl sysctl -A
gather cpuinfo cat /proc/cpuinfo
gather meminfo cat /proc/meminfo
gather lspci lspci -nn
gather lsusb lsusb
gather lsmod lsmod
gather lshw lshw
gather chkconfig chkconfig --list
gather netstat netstat -npl
gather ip-rules ip rule show
gather ip-routes ip route show
gather ifconfig ifconfig -a
gather route route -n
gather dpkg-packages dpkg -l
gather rpm-packages rpm -qa
echo " done"

cd ..
tar -zcf "${tmpdir}.tgz" $tmpdir
rm -rf $tmpdir

echo
echo "System information archive has been created:"
echo "${tmpdir}.tgz"
echo

