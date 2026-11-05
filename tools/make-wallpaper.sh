#!/bin/bash
# Makes one of the sample wallpapers. What made the ones in wallpapers/:
#   tools/make-wallpaper.sh wallpapers/automata-ash.jpg   "#151311" "#5a4a33" "#d8c6a4" "UNIT 01 · ASH"
#   tools/make-wallpaper.sh wallpapers/automata-tide.jpg  "#0b1316" "#1d4f5c" "#8fd6e6" "UNIT 02 · TIDE"
#   tools/make-wallpaper.sh wallpapers/automata-ember.jpg "#160c0c" "#5c2219" "#f0a58a" "UNIT 03 · EMBER"
# args: <out> <base> <glow> <accent> <label>
out="$1" base="$2" glow="$3" acc="$4" label="$5"
W=2560 H=1440
font="$(fc-match -f '%{file}' 'JetBrainsMono Nerd Font')"
grid=""
for x in $(seq 0 64 $W); do grid+=" line $x,0 $x,$H"; done
for y in $(seq 0 64 $H); do grid+=" line 0,$y $W,$y"; done
b=56 L=90
magick -size ${W}x${H} xc:"$base" \
  \( -size 3000x3000 radial-gradient:"$glow"-none -geometry +220-780 \) -compose screen -composite \
  \( -size ${W}x${H} xc:none -fill none -stroke "$acc" -strokewidth 1 -draw "stroke-opacity 0.06 $grid" \) -compose over -composite \
  -fill none -stroke "$acc" -strokewidth 2 -draw "stroke-opacity 0.55 circle 1720,720 1720,1110" \
  -strokewidth 1 -draw "stroke-opacity 0.25 circle 1720,720 1720,1180" \
  -strokewidth 6 -draw "stroke-opacity 0.85 arc 1330,330 2110,1110 200,250" \
  -strokewidth 1 -draw "stroke-opacity 0.3 line 1720,250 1720,1190 line 1250,720 2190,720" \
  -strokewidth 3 -draw "stroke-opacity 0.9 line $b,$b $((b+L)),$b line $b,$b $b,$((b+L)) line $((W-b)),$b $((W-b-L)),$b line $((W-b)),$b $((W-b)),$((b+L)) line $b,$((H-b)) $((b+L)),$((H-b)) line $b,$((H-b)) $b,$((H-b-L)) line $((W-b)),$((H-b)) $((W-b-L)),$((H-b)) line $((W-b)),$((H-b)) $((W-b)),$((H-b-L))" \
  -stroke none -fill "$acc" -font "$font" -pointsize 22 -kerning 6 -annotate +110+1350 "AUTOMATA.LUA  //  $label" \
  -fill "${acc}88" -pointsize 16 -annotate +110+1312 "SYS.OK   ·   HUD 0.1   ·   $(echo "$label" | tr -dc 'A-Z' | head -c3)-$(printf '%03d' $((RANDOM % 999)))" \
  -attenuate 0.15 +noise Gaussian \
  -quality 88 "$out"
