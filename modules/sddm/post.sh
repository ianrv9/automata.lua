# The login screen lives in /usr/share, so this one needs sudo. Undo steps go to system.list
#
# SDDM reads /etc/sddm.conf.d/*.conf in alphabetical order and the last one wins, so the file is
# zz-automata.conf: an old "theme.conf" with Current=other-theme would beat plain automata.conf.
# /etc/sddm.conf beats all of them, and that one is yours, so it only gets a warning.
# The menu sources this again (with SDDM_ASK) when language or fonts change, since they're baked in.
SDDM_CONF=/etc/sddm.conf.d/zz-automata.conf
if ui_confirm "${SDDM_ASK:-${T[sddm_ask]}}" no; then
    tmp="$(mktemp -d)"; cp -r "$SRC/modules/sddm/theme" "$tmp/automata"
    for f in "$tmp"/automata/*; do render "$f" > "$f.r" && mv "$f.r" "$f"; done
    # theme.conf.user belongs to you so matugen can recolor it without sudo
    if run_sudo "${T[ask_sudo]}" sh -c "cp -rT '$tmp/automata' /usr/share/sddm/themes/automata \
            && install -o '$USER' -m 644 /dev/null /usr/share/sddm/themes/automata/theme.conf.user \
            && mkdir -p /etc/sddm.conf.d && rm -f /etc/sddm.conf.d/automata.conf \
            && printf '[Theme]\nCurrent=automata\n' > $SDDM_CONF"; then
        undo="rm -rf /usr/share/sddm/themes/automata /etc/sddm.conf.d/automata.conf $SDDM_CONF"
        grep -qxF "$undo" "$STATE/system.list" 2>/dev/null || printf '%s\n' "$undo" >> "$STATE/system.list"
        "$HOME/.local/bin/change-wallpaper" --colors >/dev/null 2>&1
        ui_ok "${T[sddm_ok]}"
        ui_cmd "sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/automata"
        if grep -qsE '^[[:space:]]*Current=.+' /etc/sddm.conf && ! grep -qsx 'Current=automata' /etc/sddm.conf; then
            ui_warn "/etc/sddm.conf ${T[sddm_other]}"
        fi
    fi
    rm -rf "$tmp"
fi
