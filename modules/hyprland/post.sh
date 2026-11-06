[ -e "$HOME/.config/hypr/personal.lua" ] || cp "$SRC/modules/hyprland/personal.example.lua" "$HOME/.config/hypr/personal.lua"
ui_info "${T[personal_hint]}"
# the cursor env vars only count from the next login so I added this to change it
[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && hyprctl setcursor Bibata-Modern-Classic 24 >/dev/null 2>&1
