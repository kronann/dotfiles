#!/bin/bash
current=$(powerprofilesctl get)

cat /sys/class/power_supply/BAT1/capacity | awk '{print $1}' | xargs -I{} echo "{\"percentage\": \"{}\", \"alt\": \"$current\"}"
