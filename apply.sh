#!/bin/bash
set -e
FLAG=$1
ROOT=$(dirname $0)
NONAG="disable_nag.sh"
NOSUB="swap_ent_nosub.sh"
BAK="$ROOT/bak"
ARCHIVE="$BAK/$(date +%Y-%m-%d.%H-%M-%S).tgz"

NAG="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
APT="/etc/apt/sources.list.d"
SUB_CEPH="ceph.sources"
SUB_PVE="pve-enterprise.sources"

CHANGES=0
APT_UPDATE=0

mkdir $BAK || true

run_script() {
	set +e
	bash "$1"
	RC=$?
	set -e
	return $RC
}

tar cvfz "$ARCHIVE" $NAG $( [ -f "$APT/$SUB_PVE" ] && echo "$APT/$SUB_PVE") $( [ -f "$APT/$SUB_CEPH" ] && echo "$APT/$SUB_CEPH")

run_script "$ROOT/$NOSUB"
if [ $? -eq 0 ]; then
	CHANGES=1
	apt update
	if [ "$FLAG" = "first-setup" ]; then
		apt upgrade -y
	fi
else
	echo "enterprise repos already disabled"
fi

run_script "$ROOT/$NONAG"

if [ $? -eq 0 ]; then
	CHANGES=1
	systemctl restart pveproxy
else
	echo "nag already disabled"
fi

if [ $CHANGES -lt 1 ]; then
	echo "no changes, deleting backup file"
	rm $ARCHIVE
else
	echo "backup file $ARCHIVE"
fi
