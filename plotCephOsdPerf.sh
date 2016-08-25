#!/bin/bash

# Set some default values - might be owerwritten by arguments,
LogFile=/dev/null

function show_help 
{
    echo "
    
    Usage: 
    
    $0 [options]
    
    Options:
    -h      Show this help screen

    -s      Hostname or IP number of host
    -u      Username for login
    -d      Device to monitor
    -l      Store the data in a logfile (default: /dev/null)

    
    
    "
    exit
}





#Parse arguments
while getopts "h:u:p:s:d:" opt; do
    case $opt in
        h)
            show_help
            ;;
        u)
            username=$OPTARG
            ;;
        p)
            password=$OPTARG
            ;;
        s)
            hostname=$OPTARG
            ;;
        d)
            device=$OPTARG
            ;;
        l)
            LogFile=$OPTARG
            ;;

    esac
done

echo $username $password $hostname $device





while true; do
    sleep 1
    echo $(date +"%Y-%m-%d+%H:%M:%S") \
         $(sshpass -p "$password" ssh "$username"@"$hostname" ceph osd perf \
           | grep  -v osd  | awk 'BEGIN {high_commit=0; high_apply=0} \
               {commit+=$2; apply+=$3;  if ($2>high_commit) high_commit=$2; if ($3>high_apply) high_apply=$3} \
               END {print commit/NR " " apply/NR " " high_commit " " high_apply}' )
done | \
    feedgnuplot --"timefmt %Y-%m-%d+%H:%M:%S" \
        --domain \
        --stream \
        --lines \
        --legend 0 "Commit latency" \
        --legend 1 "Apply latency" \
	--legend 2 "Highest commit latency" \
        --legend 3 "Highest apply latency" \
        --title "$hostname: Ceph monitor performance" \
        --exit
