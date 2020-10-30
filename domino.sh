#!/bin/sh
#
# A startup script for the Lotus Domino 6 server
#
# chkconfig: 345 95 5
# description: This script is used to start the domino \
# server as a background process.\
#
# Usage /etc/init.d/domino start|stop|status|restart

# Since RH9 includes better handling of the tweaks recommended by
# IBM in their redbooks and this script was written for RH9 and Domino 6,
# any reference to the tweaks have been removed.  The modifications add the
# status and restart options for the domino service.

# This script is a combination of IBM's domino script and their startserver
# script with slight modifications.

# You should change the 3 following variables to reflect your environment.

# DOM_HOME is the variable that tells the script where the Domino Data resides
DOM_HOME=/local/dominodata

# DOM_USER is the Linux account used to run the Domino 6 server
DOM_USER=notes

# DOM_PROG is the location of the Domino executables
DOM_PROG=/opt/ibm/domino/bin

# Source function library 
. /lib/lsb/init-functions

# Set the prog variable for the status line of the code
prog=$DOM_PROG/server

# Does the lock file exist?
config () {
	if [ -f $DOM_HOME/.jsc_lock ]; then
		rm -f $DOM_HOME/.jsc_lock
	fi
}

# Let's start the server
start() {
	echo -n "Starting domino: "
	ulimit -n 20000
	config
	cd $DOM_HOME 
	su - $DOM_USER -c "$DOM_PROG/server -jc -c > /dev/null 2>&1 &"
	return 0
}

# Let's stop the server
stop() {
	echo -n "Stopping domino server: "
	su - $DOM_USER -c "$DOM_PROG/server -q"
	sleep 5
	echo -n "Is the controller running?  If so, stopping it: "
	check_controller='netstat -an | grep " LISTEN" | grep 2050'
	if [ "$check_controller" ]
	then
		echo -n "Domino controller appears to be running - stopping..."
		echo Y | su - $DOM_USER -c "$DOM_PROG/server -jc -q";echo ''
		sleep 5
	fi
	return 0
}

# Let's stop and restart the server.
restart() {
	echo -n "Beginning restart script..."
	check_controller='netstat -an | grep " LISTEN" | grep 2050'
	if [ "$check_controller" ]
	then
		echo -n "Domino controller appears to be running - stopping..."
		echo Y | su - $DOM_USER -c "$DOM_PROG/server -jc -q";echo ''
		sleep 5
	else
		check_server='ps -A | grep replica'
		if [ "$check_server" ]
		then
			echo -n "Domino server appears to be running - stopping..."
			su - $DOM_USER -c "$DOM_PROG/server -q"
			sleep 5
		fi
	fi
	echo -n "Starting Domino Controller and Server..."
	config
	cd $DOM_HOME 
	su - $DOM_USER -c "$DOM_PROG/server -jc -c > /dev/null 2>&1 &"
	sleep 5
	echo -n "Domino Server restart complete..."
} 

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart)
	restart
	;;
status)
	status $prog 
	;;
*)
	echo "Usage: domino {start|stop|status|restart}"
	exit 1
esac