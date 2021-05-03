#!/usr/bin/env bash

#set -x

#############################################################################
#                                                                           #
# Name: monitor_col_nmon.sh                                                 #
# Path: N/A                                                                 #
# Host(s): N/A                                                              #
# Info: Script to monitor performance data collection from host             #
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
    
    printf "Usage: %s \n" $0
    printf "       -s <sample>: duration in seconds of each data collection\n"
    printf "       -h|?: help\n"
    
}


#############################################################################
# Script main logic                                                         #
#############################################################################

sflag="0"
while getopts ":s:h" opt
do
    case $opt in
        s )
            sflag="1"
            SECS="$OPTARG"
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

PSCOUNT=$(ps -eF | grep "n[m]on -f -D -F" | wc -l)
if (($PSCOUNT == 0))
then
    if (($sflag == 0))
    then
        nohup /usr/local/scripts/col_nmon.sh &
    else
        nohup /usr/local/scripts/col_nmon.sh -s ${SECS} &
    fi
fi
