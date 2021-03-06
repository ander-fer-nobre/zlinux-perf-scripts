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
# Name: monitor_col_dasdstat.sh                                             #
# Path: N/A                                                                 #
# Host(s): N/A                                                              #
# Info: Script to monitor dasdstat data collection from zLinux host         #
#                                                                           #
# Author: Anderson F Nobre                                                  #
# Creation date: 25/03/2021                                                 #
# Version: 0.1                                                              #
#                                                                           #
# Modification date: DD/MM/YYYY                                             #
# Modified by: XXXXXXXXXXXXXXXXX                                            #
# Modifications:                                                            #
# - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX         #
#                                                                           #
#############################################################################


#############################################################################
# Environment variables                                                     #
#############################################################################

COL_DIR=/var/perf/dasdstat
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

PSCOUNT=$(ps -eF | grep "col_da[s]dstat" | grep -v monitor | wc -l)
if (($PSCOUNT == 0))
then
    if (($sflag == 0))
    then
        nohup /usr/local/scripts/col_dasdstat.sh &
    else
        nohup /usr/local/scripts/col_dasdstat.sh -s ${SECS} &
    fi
fi
