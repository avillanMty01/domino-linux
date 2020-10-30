#! /bin/sh
# Copyright (c) 2002 - 2008, Alfa Tecnologias Mexico.
#
# Alfonso Villanueva <consultoria@alftec.com>
#

### BEGIN INIT INFO
# Provides:       Lotus Domino
# Required-Start: $network
# Default-Start:  3 5
# Default-Stop:   3 5
# Description:    init script for the Lotus Domino Server
### END INIT INFO
#

# init.d/domino
#
# as a background process. It will read
# the serverID password from a file to the
# server. Communication with the server
# has to be done through cconsole, Notes
# Administrator or webadmin.

#
# NOTE: starting with Domino 7.x, it's required to have ulimit set to 20000
#       please see the Release Notes for more info.
#
# Usage /etc/rc.d/init.d/domino start|stop
#
# Change the USER, GROUP, DATA_DIR and BIN_DIR for your server

DOMINO_NAME="Arena Monterrey" # Display name
DOMINO_USER="notes" # Domino User
DOMINO_GROUP="notes" # Domino User Group
DOMINO_DATA_DIR="/data/dcorp" # Location of notes.ini
DOMINO_BIN_DIR="/opt/ibm/lotus/bin" # Location of binaries

# We need a file to put the serverID password in.
# Make sure owner is the Domino owner and the file
# permission is set to 400.
SERVER_PASSWD_FILE="/data/dcorp/.domino.pwd"

# Look if the user that runs this script is root

if [ `id -u` != 0 ]; then
echo "This script must be run by root only"
exit 1;
fi

# See how we are called.
case "$1" in
    start)

        # First check if the password file exist,
        # if not exit with errorcode

        # [ -f file ] : true if file exist and is
        # regular file
        # ! expr : true is expr is false
        if [ ! -f $SERVER_PASSWD_FILE ]; then
        echo "Error: No password file."
        exit 1
        fi

        # Set permission to 400 (read-only-owner)

        # and ownership to $DOMINO_USER.
        chmod 400 $SERVER_PASSWD_FILE
        chown $DOMINO_USER.$DOMINO_GROUP $SERVER_PASSWD_FILE

        # As specified in the R7 Release Notes
        ulimit -n 20000

        # Two ways to run the server (comment on of
        # them out):
        # 1. With the output of the console redirected
        # to the log file /var/log/domin.log. Be sure
        # to change the logrotate daemon
        # 2. With output of the console redirected
        # to /dev/null
        echo -n "Starting Domino server $DOMINO_NAME..."

        # Version with logfile (selected by default)
        #su - ${DOMINO_USER} -c "cd ${DOMINO_DATA_DIR};\
        #cat ${SERVER_PASSWD_FILE} |\
        #${DOMINO_BIN_DIR}/server" >\
        # /var/log/domino.log 2>&1 &

        # Version without logfile
        su - ${DOMINO_USER} -c "cd ${DOMINO_DATA_DIR};\
        cat ${SERVER_PASSWD_FILE} |\
        ${DOMINO_BIN_DIR}/server" >\
        /dev/null 2>&1 &
        echo "done."
        ;;

    stop)
        ulimit -n 20000
        echo -n "Stopping Domino server $DOMINO_NAME..."
        su - ${DOMINO_USER} -c "cd ${DOMINO_DATA_DIR};\
        ${DOMINO_BIN_DIR}/server -q"
        ;;
        *)
        echo "Usage: domino {start|stop}"

        exit 1

esac

exit 0
