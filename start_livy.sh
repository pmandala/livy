#!/bin/bash

. "/opt/livy/bin/load-spark-env.sh"

env 

/opt/livy/bin/livy-server start

tail -f /dev/null

