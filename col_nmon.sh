#!/usr/bin/env bash

#set -x

#############################################################################
#                                                                           #
# Name: col_nmon.sh                                                         #
# Path: N/A                                                                 #
# Host(s): N/A                                                              #
# Info: Script to collect nmon performance data                             #
#                                                                           #
# Author: Anderson F Nobre                                                  #
# Creation date: 26/10/2016                                                 #
# Version: 0.1                                                              #
#                                                                           #
# Modification date: DD/MM/YYYY                                             #
# Modified by: XXXXXXXXXXXXXXXX                                             #
# Modifications:                                                            #
# - XXXXXXXXXXXXXXXXXXXXXXXXXXX                                             #
#                                                                           #
#############################################################################


#############################################################################
# Environment variables                                                     #
#############################################################################

COL_DIR=/var/perf/nmon
HOST=$(hostname)
DATE=$(date +"%Y%m%d")
TIME=$(date +"%H%M%S")
NMONTXT=nmon_${HOST}_${DATE}_${TIME}.nmon


#############################################################################
# Function definitions                                                      #
#############################################################################

#----------------------------------------------------------------------------
# Function: usage
# 
# Arguments:
# - N/A
# 
# Retun:
# - N/A

function usage {
    
cat <<EOF
    Usage: $0 [-s <sample>] [-c <count>] [-D <collect dir>] [-d <days>]
           -s <sample>
                duration in seconds of each data collection
           -c <count>
                number of times to collect performance data
           -D <collect dir>
                performance collection directory
                Default directory is ${COL_DIR}
           -d <days>
                number of days to compress older nmon files
           -h|?
                help
EOF
 
}

#----------------------------------------------------------------------------
# Function: get_remain_secs
# 
# Arguments:
# - N/A
# 
# Retun:
# - remain_secs Remain seconds from now till end of day

function get_remain_secs {
    
    echo $(($(date -d 23:59:59 +%s) - $(date +%s) + 1))
    
}



#############################################################################
# Script main logic                                                         #
#############################################################################


# Set default values for SECS and COUNT
SECS="60"
DIFF_SECS=$(get_remain_secs)
COUNT="$((${DIFF_SECS} / ${SECS}))"
Dflag="0"
cflag="0"
dflag="0"
sflag="0"

while getopts ":D:s:c:d:" opt
do
    case $opt in
        D )
            Dflag="1"
            COL_DIR="$OPTARG"
            ;;
        s )
            sflag="1"
            SECS="$OPTARG"
            ;;
        c )
            cflag="1"
            COUNT="$OPTARG"
            ;;
        d )
            dflag="1"
            DAYS="$OPTARG"
            ;;
        h|\? )
            usage
            exit 2
            ;;
        * )
            usage
            exit -1
            ;;
    esac
done

shift $((OPTIND - 1))

# Create COLDIR if it doesn't exist
if [[ ! -d ${COL_DIR} ]]
then
    mkdir -p ${COL_DIR}
    RC=$?
    if (( $RC != 0 ))
    then
        printf "Couldn't create directory %s!!!\n" ${COL_DIR}
        exit -1
    fi
fi

# Start data collection
if (( $dflag == 0 ))
then
    cd ${COL_DIR}
    RC=$?
    if (( $RC == 0 ))
    then
        /usr/bin/nmon -f -D -F ${COL_DIR}/${NMONTXT} -g auto -l 40 -M -N -T -U -c $COUNT -s $SECS
    fi
else
# Purge oldest data collected
    find ${COL_DIR} -xdev -name \*.nmon -mtime +${DAYS} -exec bzip2 {} \;
fi
