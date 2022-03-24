#!/bin/bash
#
# montar.sh
# mounts remote backup to restore
# Carlos Escutia
# last modified: 06/08/21 dd/mm/yy
#

source config

mkdir -p $mountpoint
borg mount ssh://$backupuser@$backupserver:$backupport/$backupdir/$project/ $mountpoint
