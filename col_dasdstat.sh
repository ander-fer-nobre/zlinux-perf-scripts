#!/bin/bash

#set -x

# Copyright 2021 IBM Systems Lab Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an “AS IS” BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#############################################################################
#                                                                           #
# Name: col_dasdstat.sh                                                     #
# Path: N/A                                                                 #
# Host(s): N/A                                                              #
# Info: Script to collect dasdstat data from zLinux host                    #
#                                                                           #
# Author: Anderson F Nobre                                                  #
# Creation date: 25/03/2021                                                 #
# Version: 0.1                                                              #
#                                                                           #
# Modification date: DD/MM/YYYY                                             #
# Modified by: XXXXXXXXXXXXXXXX                                             #
# Modifications:                                                            #
# - XXXXXXXXXXXXXXXXXXXXXXXXXX                                              #
#                                                                           #
#############################################################################


#############################################################################
# Environment variables                                                     #
#############################################################################

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin
# Directory's data collection
COL_DIR=/var/perf/dasdstat
HOST=$(hostname)
DATE=$(date +"%Y%m%d")
TIME=$(date +"%H%M%S")
DASDTXT="dasdstat_${HOST}_${DATE}_${TIME}.dst"


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
           -s <sample>: duration in seconds of each data collection
           -c <count>: number of times to collect performance data
           -D <collect dir>: performance collection directory
                Default directory is ${COL_DIR}
           -d <days>: number of days to compress older nmon files
           -h|?: help
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

#----------------------------------------------------------------------------
# Function: check_dasdstat
#
# Arguments:
# - N/A
#
# Retun:
# - N/A

function check_dasdstat {

    type dasdstat
    RC=$?
    if (( $RC != 0 ))
    then
        printf "dasdstat command not installed!!!\n"
        exit -1
    fi

    # Enabling dasdstat on dasd...
    dasdstat -e global
    for DASD in $(lsdasd | grep active | awk '{print $3}')
    do
        dasdstat -e ${DASD}
    done

}

#----------------------------------------------------------------------------
# Function: dasdstat_dump
#
# Arguments:
# - SECS: Interval in seconds
# - COUNT: Number of samples
#
# Retun:
# - N/A

function dasdstat_dump {
    
    for ((i=1; i<=$2; i++))
    do
        dasdstat -l global
        for DASD in $(lsdasd | grep active | awk '{print $3}')
        do
            dasdstat -l ${DASD}
        done
        sleep $1
    done
     
}


#############################################################################
# Script main logic                                                         #
#############################################################################

# Set default number of days to compress data
DAYS="3"

# Set default values for SECS and COUNT
SECS="60"
DIFF_SECS=$(get_remain_secs)
COUNT="$((${DIFF_SECS} / ${SECS}))"

# Set initial flag values
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

# If only the sample (SECS) is set, then recalculate the number of intervals
if (( $sflag == 1 && $cflag == 0 ))
then
    COUNT="$((${DIFF_SECS} / ${SECS}))"
fi

# Check if data collection directory exists, if not create it
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

# Check if dstat command exists
check_dasdstat

# Start data collection
if (( $dflag == 0 ))
then
    cd ${COL_DIR}
    RC=$?
    if (( $RC == 0 ))
    then
        dasdstat_dump ${SECS} ${COUNT} >> ${COL_DIR}/${DASDTXT}
    else
        printf "Couldn\'t change to directory %s\n" ${COL_DIR}
    fi
else
# Purge oldest data collected
    cd ${COL_DIR}
    RC=$?
    if (( $RC == 0 ))
    then
        find ${COL_DIR} -xdev -name \*.dst -mtime +${DAYS} -exec bzip2 {} \;
    else
        printf "Couldn\'t change to directory %s\n" ${COL_DIR}
    fi
fi
