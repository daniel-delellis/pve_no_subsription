#!/bin/bash
JS=/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
MATCH=$(awk "/url: \'\/nodes\/localhost\/subscription/ {print FNR}" "$JS")
HEAD=$((MATCH-2))
TAIL=$((HEAD+1))

noop() {
	echo "Nag already disabled"
	exit 1
}

replace() {
	mv $1 $JS
	systemctl restart pveproxy
}

grep -q "//nag buster" $JS && noop 

sed -n "1,${HEAD}p" $JS > current 
echo "//nag buster!" >> current
echo "if (true) {orig_cmd(); return;};" >> current
echo "//nag busted!" >> current
sed -n "${TAIL},\$p" $JS >> current

replace current
