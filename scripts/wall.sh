#!/bin/sh
# Changes the wallpaper to a randomly chosen image in a given directory
# at a set interval.

  TIMEOUT=21600

  for pid in $(pidof -o %PPID -x wallsetter); do
  	kill $pid
  done

  if ! [ -d ~/rudra/config/assets ]; then notify-send -t 5000 "~/Pictures/Wallpapers does not exist" && exit 1; fi
  if [ $(ls -1 ~/rudra/config/assets | wc -l) -lt 1 ]; then	notify-send -t 9000 "The wallpaper folder is expected to have more than 1 image. Exiting Wallsetter." && exit 1; fi

  while true; do
    while [ "$WALLPAPER" == "$PREVIOUS" ]; do
      WALLPAPER=$(find ~/rudra/config/assets -name '*' | awk '!/.git/' | tail -n +2 | shuf -n 1)
    done

  	PREVIOUS=$WALLPAPER

  	swww img "$WALLPAPER" --transition-type random --transition-step 1 --transition-fps 60
  	sleep $TIMEOUT
  done
''
