#!/bin/bash
set -e
ROOT=$(dirname $0)

PATCHES="$ROOT/patches"
APT="/etc/apt/sources.list.d"
SUB_CEPH="ceph.sources"
NOSUB_CEPH="ceph-no-subscription.sources"

SUB_PVE="pve-enterprise.sources"
NOSUB_PVE="pve-no-subscription.sources"

NAG="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
NAG_VER=$(head -n1 $NAG | awk {'print $NF'})
NAG_PATCH="$PATCHES/nag/$NAG_VER/nonag.patch"

BAK="$ROOT/bak"
ARCHIVE="$BAK/$(date +%Y-%m-%d.%H-%M-%S).tgz"

CHANGES=0
APT_UPDATE=0

dpkg -l | grep patch || apt install -y patch
if [ ! -d $BAK ]; then
	mkdir $BAK
fi


tar cvfz "$ARCHIVE" $NAG  $( [ -f "$APT/$SUB_PVE" ] && echo "$APT/$SUB_PVE") $( [ -f "$APT/$SUB_CEPH" ] && echo "$APT/$SUB_CEPH")

if [ ! -f "$APT/$NOSUB_CEPH" ]; then
	patch $APT/$SUB_CEPH "$PATCHES/apt/ceph.patch"
	mv "$APT/$SUB_CEPH" "$APT/$NOSUB_CEPH"
	CHANGES=$((CHANGES+1))
	APT_UPDATE=1
else
	echo "$NOSUB_CEPH already created"
fi

if [ ! -f "$APT/$NOSUB_PVE" ]; then
	patch $APT/$SUB_PVE "$PATCHES/apt/pve-enterprise.patch"
	mv "$APT/$SUB_PVE" "$APT/$NOSUB_PVE"
	CHANGES=$((CHANGES+1))
	APT_UPDATE=1
else
	echo "$NOSUB_PVE already created"
fi

echo $NAG_VER | grep -q "\.nag-disabled$" && echo "subscription nag already disabled" && exit 0

if [ -f "$NAG_PATCH" ]; then
	patch $NAG $NAG_PATCH
	systemctl restart pveproxy
	CHANGES=$((CHANGES+1))
else
	echo "proxmox-widget-toolkit:$NAG_VER not yet supported"
fi

if [ $CHANGES -lt 1 ]; then
	echo "no changes, deleting backup file"
	rm $ARCHIVE
fi

if [ $APT_UPDATE -gt 0 ]; then
	apt update
fi
