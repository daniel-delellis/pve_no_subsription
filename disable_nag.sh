#!/bin/bash
JS=/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
MATCH=$(awk "/url: \'\/nodes\/localhost\/subscription/ {print FNR}" "$JS")
HEAD=$((MATCH-2))
TAIL=$((HEAD+1))

noop() {
	exit 1
}

replace() {
	mv $1 $JS
}

grep -q "//nag buster" $JS && noop

sed -n "1,${HEAD}p" $JS > current
echo "//nag buster!" >> current
echo "            orig_cmd(); }, nag_unbusted: function(orig_cmd) {" >> current
echo "//nag busted!" >> current
sed -n "${TAIL},\$p" $JS >> current

replace current
