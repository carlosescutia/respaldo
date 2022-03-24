#!/bin/bash
#
# desmontar.sh
# unmounts remote backup
# # Carlos Escutia
# last modified: 06/08/21 dd/mm/yy
#

source config

umount $mountpoint
rmdir $mountpoint
