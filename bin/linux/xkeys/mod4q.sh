#!/bin/bash
W=`xdotool getactivewindow`
S1=`xprop -id ${W} |awk '/WM_CLASS/{print $4}'`
if [[ $S1 =~ "Terminator" ]]; then
  xdotool key --delay 0 --clearmodifiers "ctrl+shift+q"
elif [[ $S1 =~ "Gnome-terminal" ]]; then
  xdotool key --delay 0 --clearmodifiers "ctrl+shift+q"
else
  xdotool key --delay 0 --clearmodifiers "ctrl+q"
fi
