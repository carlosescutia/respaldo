#!/bin/bash
#
# init.sh
# initializes project repository in remote server
# Carlos Escutia
# last modified: 06/08/21 dd/mm/yy
#

source config

borg init -e repokey-blake2 ssh://$backupuser@$backupserver:$backupport/$backupdir/$project/
