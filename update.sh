#!/bin/bash
ROOT=$(dirname $0)
tar cvf "$ROOT/../pve-no-subscription.$(date +%s).tar" -C $ROOT $(ls $ROOT | grep "\.sh$" )
