#!/bin/bash
current=$(powerprofilesctl get)
case "$current" in
    "power-saver")
        powerprofilesctl set balanced
        echo "balanced"
        ;;
    "balanced")
        powerprofilesctl set performance
        echo "performance"
        ;;
    "performance")
        powerprofilesctl set power-saver
        echo "power-saver"
        ;;
    *)
        powerprofilesctl set balanced
        echo "balanced"
        ;;
esac
