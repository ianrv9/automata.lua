if "$HOME/.local/bin/firefox-hud" --install >/dev/null; then ui_ok "${T[ff_ok]}"
else ui_warn "${T[ff_no_profile]}"; fi
if command -v pywalfox >/dev/null; then
    pywalfox install >/dev/null 2>&1
    ui_info "${T[ff_pywalfox]} https://addons.mozilla.org/firefox/addon/pywalfox/"
fi
