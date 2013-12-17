#!/bin/bash
#
# Job pool implementation in BASH
# License: Apache 2.0
# Author: Michael Spector <spektom@gmail.com>
#

pool_id=$1
shift
pool_size=$1
shift
if [ -z "$pool_id" ] || [ -z "$pool_size" ] || [ $# -eq 0 ]; then
	echo
	echo "USAGE: $0 <ID> <limit> <command>"
	echo
	echo "Where:"
	echo "  <ID>       Job pool identifier"
	echo "  <limit>    Job pool size"
	echo "  <command>  Command to run"
	echo
	exit 1
fi

pool_id=$(echo $pool_id | sed 's/\W/_/g')
workdir="/tmp/$(whoami)-jp"
[ -d $workdir ] || mkdir -p $workdir || exit $?
lock_prefix="$workdir/$pool_id"
lock_file="$lock_prefix.$$"

lock() {
	# Critical section:
	(
		flock -x 201 || exit 1

		# Wait for other processes to finish
		num_running=0
		for l in $(eval ls "${lock_prefix}.*" 2>/dev/null); do
			if kill -0 $(echo $l | sed 's/.*\.//'); then
				num_running=$(($num_running+1))
			else
				# Remove lock file for non-existent process
				rm -f $l
			fi
		done
		if [ $num_running -lt $pool_size ]; then
			touch $lock_file
			return 0
		fi
		return 1

	) 201>$workdir/.lock
}

unlock() {
	rm -f $lock_file
}

trap "unlock; exit 0" INT TERM EXIT

while ! lock; do
	# Waiting for some process to exit
	sleep 1
done

# Run the command
"$@"

