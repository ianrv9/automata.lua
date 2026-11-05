line='[ -f ~/.config/bash/automata.sh ] && . ~/.config/bash/automata.sh'
if grep -qxF "$line" "$HOME/.bashrc" 2>/dev/null; then ui_ok "${T[bashrc_already]}"
elif ui_confirm "${T[bashrc_ask]}"; then
    printf '\n# automata.lua\n%s\n' "$line" >> "$HOME/.bashrc"     # uninstall looks for that marker
    ui_ok "${T[bashrc_ok]}"
else
    ui_info "${T[bashrc_manual]} $line"
fi
