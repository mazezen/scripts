#!/bin/sh

# clean docker containers logs

logs=$(find /var/lib/docker/containers/ -name *-json.log)

for log in $logs
        do
                echo "clean logs : $log"  
                cat /dev/null > $log
        done
