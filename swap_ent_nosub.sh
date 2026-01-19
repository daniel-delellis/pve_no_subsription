#!/bin/bash
FLAG=$1

APT="/etc/apt/sources.list.d"
BAK="bak.$(date +%s)"

ENT_CEPH="ceph.sources"
NOSUB_CEPH="ceph-no-subscription.sources"

ENT_PVE="pve-enterprise.sources"
NOSUB_PVE="pve-no-subscription.sources"

APT_UPDATE=1

edit_sources() {
	sed 's%https://enterprise%http://download%;s/enterprise/no-subscription/' $1 -i
}

check_and_update() {
	NEW="$APT/$1"
	ORIG="$APT/$2"
	if [ ! -f "$NEW" ]; then
		edit_sources "$ORIG"
		mv "$ORIG" "$NEW"
		APT_UPDATE=0
	fi
}

check_and_update $NOSUB_CEPH $ENT_CEPH
check_and_update $NOSUB_PVE $ENT_PVE

exit $APT_UPDATE
