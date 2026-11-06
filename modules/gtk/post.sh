# The colors only work with the adw-gtk3 theme (they use libadwaita's color names), and GTK4 apps
# just need "prefer dark". That's all in gsettings, not in a file, so the old values get written
# to gsettings.restore first and uninstall plays them back.
gtk_set() {     # gtk_set key value
    local old restore="$STATE/gsettings.restore"
    old="$(gsettings get org.gnome.desktop.interface "$1" 2>/dev/null)" || return 0
    grep -qs " $1 " "$restore" || printf 'gsettings set org.gnome.desktop.interface %s "%s"\n' "$1" "$old" >> "$restore"
    gsettings set org.gnome.desktop.interface "$1" "$2"
}
if command -v gsettings >/dev/null; then
    gtk_set gtk-theme adw-gtk3-dark
    gtk_set color-scheme prefer-dark
    gtk_set font-name "$FONT_UI 11"
    if is_installed hyprland; then
        gtk_set cursor-theme Bibata-Modern-Classic
        gtk_set cursor-size 24
    fi
fi
# a settings.ini with another theme wins over gsettings
ini="$HOME/.config/gtk-3.0/settings.ini"
if grep -qsE '^gtk-theme-name=' "$ini" && ! grep -qs '^gtk-theme-name=adw-gtk3' "$ini"; then
    ui_warn "${ini/#$HOME/\~} ${T[gtk_ini]}"
fi
