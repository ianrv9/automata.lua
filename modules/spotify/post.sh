if ! command -v spicetify >/dev/null; then ui_warn "${T[spotify_no_cli]}"; return 0; fi
[ -n "$SPOTIFY_PATH" ] || return 0
spicetify config current_theme automata color_scheme automata inject_theme_js 1 inject_css 1 replace_colors 1 >/dev/null
if ui_confirm "${T[spotify_apply]}"; then
    # "backup apply" fails if there's an old backup lying around, "restore backup apply" sorts that out
    { spicetify backup apply || spicetify restore backup apply; } >/dev/null 2>&1 && ui_ok "${T[spotify_applied]}"
fi
ui_info "${T[spotify_update]}"
