#!/bin/bash
#
# info.sh
# shows info about backup repository
# Carlos Escutia
# last modified: 10/08/21 dd/mm/yy
#

source config

borg info ssh://$backupuser@$backupserver:$backupport/$backupdir/$project/
