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

while true; do
    sleep 1
    echo $(date +"%Y-%m-%d+%H:%M:%S") \
         $(sshpass -p "$password" ssh "$username"@"$hostname" iostat -y 2 1 \
             | grep $device | awk '{kBread+=$3; kBwrite+=$4} END {print kBread " " kBwrite }'  )
done | \
    feedgnuplot --"timefmt %Y-%m-%d+%H:%M:%S" \
        --domain \
        --stream \
        --lines \
        --legend 0 "kB_Read/s" \
        --legend 1 "kB_Write/s" \
        --ylabel "kB/s" \
        --title "$hostname: Throughput for $device" \
        --exit
