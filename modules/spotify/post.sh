if ! command -v spicetify >/dev/null; then ui_warn "${T[spotify_no_cli]}"; return 0; fi
[ -n "$SPOTIFY_PATH" ] || return 0
spicetify config current_theme automata color_scheme automata inject_theme_js 1 inject_css 1 replace_colors 1 >/dev/null </dev/null
if ui_confirm "${T[spotify_apply]}"; then
    # "backup apply" fails if an old backup is lying around, "restore backup apply" sorts that out.
    # stdin is closed so a surprise "update spicetify? [y/n]" can't hang us forever
    spicetify_apply() { spicetify backup apply || spicetify restore backup apply; }
    if ui_busy "${T[busy_spotify]}" spicetify_apply >/dev/null; then ui_ok "${T[spotify_applied]}"
    else ui_warn "${T[spotify_failed]}"; fi
fi
ui_info "${T[spotify_update]}"
