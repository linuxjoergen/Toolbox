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

sshpass -p  "$password" ssh "$username"@"$hostname" ifstat -i "$device" | \
    stdbuf -i0 -o0 -e0 grep -oE "\-?[0-9].[0-9].*[0-9].[0-9]*" | \
    while read i; do 
         echo $(date +"%Y-%m-%d+%H:%M:%S") $i
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
