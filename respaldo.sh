#!/bin/bash
#
# respaldo.sh
# backs up project to remote server
# Carlos Escutia
# last modified: 06/08/21 dd/mm/yy
#

source config

borg create --stats --progress --compress $compression ssh://$backupuser@$backupserver:$backupport/$backupdir/$project/::`echo $project`_`date +%Y-%m-%d-%H-%M` ../ --exclude=../respaldo
