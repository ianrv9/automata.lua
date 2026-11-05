# The login screen lives in /usr/share, so this one needs sudo. Undo steps go to system.list
if ui_confirm "${T[sddm_ask]}" no; then
    tmp="$(mktemp -d)"; cp -r "$SRC/modules/sddm/theme" "$tmp/automata"
    for f in "$tmp"/automata/*; do render "$f" > "$f.r" && mv "$f.r" "$f"; done
    # theme.conf.user belongs to you so matugen can recolor it without sudo
    if run_sudo "${T[ask_sudo]}" sh -c "cp -rT '$tmp/automata' /usr/share/sddm/themes/automata \
            && install -o '$USER' -m 644 /dev/null /usr/share/sddm/themes/automata/theme.conf.user \
            && mkdir -p /etc/sddm.conf.d \
            && printf '[Theme]\nCurrent=automata\n' > /etc/sddm.conf.d/automata.conf"; then
        printf '%s\n' "rm -rf /usr/share/sddm/themes/automata /etc/sddm.conf.d/automata.conf" >> "$STATE/system.list"
        "$HOME/.local/bin/change-wallpaper" --colors >/dev/null 2>&1
        ui_ok "${T[sddm_ok]}"
    fi
    rm -rf "$tmp"
fi
