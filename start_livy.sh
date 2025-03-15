#!/bin/sh
set -e

echo -e "\nExecuting `basename "$0"` script as user: `whoami`"
uname -a

/opt/livy/bin/livy-server start

tail -f /dev/null

