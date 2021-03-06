#!/bin/bash

. ~/env/instance_sched.sh
. ./MI/functions_pam.sh

if $use_pam ; then
    setPamPassword
fi

for i in `ls | grep ^R | sort` ; do
    if [ -d "$i" ]; then
        echo "-  $i"
        cd "$i" 
        for j in *.sh ; do
          bash ./$j
        done 
        cd ..
    fi
done

exit 0