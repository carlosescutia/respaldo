#!/bin/bash
#
# lista.sh
# lists backups on remote server
# Carlos Escutia
# last modified: 06/08/21 dd/mm/yy
#

source config

borg list -v ssh://$backupuser@$backupserver:$backupport/$backupdir/$project/
