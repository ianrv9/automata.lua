# Terminal UI. Uses gum when it's around, plain read/echo when it isn't.
# Colors come from your wallpaper (palette.sh is a matugen output), so the
# installer matches the desktop. Before the first wallpaper: defaults below.

ACCENT="#b6c4ff" ACCENT2="#f5aefe" ON_ACCENT="#1e2f60" TEXT="#e3e1e9" DIM="#c5c6d0" LINE="#444651" ERR="#ffb4ab"
[ -f "$HOME/.config/automata/palette.sh" ] && . "$HOME/.config/automata/palette.sh"

USE_GUM=0
command -v gum >/dev/null && [ -t 0 ] && [ -t 1 ] && USE_GUM=1

# "#rrggbb" -> truecolor escape
_fg() { local h="${1#\#}"; printf '\e[38;2;%d;%d;%dm' "0x${h:0:2}" "0x${h:2:2}" "0x${h:4:2}"; }
if [ -t 1 ]; then
    C_A="$(_fg "$ACCENT")" C_A2="$(_fg "$ACCENT2")" C_T="$(_fg "$TEXT")" C_D="$(_fg "$DIM")" C_L="$(_fg "$LINE")" C_E="$(_fg "$ERR")"
    C_B=$'\e[1m' C_0=$'\e[0m'
else
    C_A="" C_A2="" C_T="" C_D="" C_L="" C_E="" C_B="" C_0=""
fi

# gum reads its style from env vars, so theming it is just this
export GUM_CHOOSE_CURSOR="▸ " GUM_CHOOSE_CURSOR_FOREGROUND="$ACCENT" GUM_CHOOSE_HEADER_FOREGROUND="$DIM"
export GUM_CHOOSE_SELECTED_FOREGROUND="$ACCENT" GUM_CHOOSE_ITEM_FOREGROUND="$TEXT"
export GUM_CHOOSE_SELECTED_PREFIX="■ " GUM_CHOOSE_UNSELECTED_PREFIX="□ " GUM_CHOOSE_CURSOR_PREFIX="□ "
export GUM_INPUT_CURSOR_FOREGROUND="$ACCENT" GUM_INPUT_PROMPT_FOREGROUND="$ACCENT" GUM_INPUT_HEADER_FOREGROUND="$DIM"
export GUM_INPUT_PROMPT="▸ "
export GUM_CONFIRM_SELECTED_BACKGROUND="$ACCENT" GUM_CONFIRM_SELECTED_FOREGROUND="$ON_ACCENT"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="$LINE" GUM_CONFIRM_UNSELECTED_FOREGROUND="$TEXT"
export GUM_CONFIRM_PROMPT_FOREGROUND="$TEXT"
export GUM_SPIN_SPINNER="minidot" GUM_SPIN_SPINNER_FOREGROUND="$ACCENT" GUM_SPIN_TITLE_FOREGROUND="$DIM"

# Big header with corner brackets, same as the panels on the desktop
ui_banner() {   # ui_banner "subtitle"
    local w=52
    printf '\n%s┌─%*s─┐%s\n' "$C_A" $((w - 4)) "" "$C_0"
    printf '%s   ▄▀█ █ █ ▀█▀ █▀█ █▀▄▀█ ▄▀█ ▀█▀ ▄▀█   █   █ █ ▄▀█%s\n' "$C_T" "$C_0"
    printf '%s   █▀█ █▄█  █  █▄█ █ ▀ █ █▀█  █  █▀█ ▄ █▄▄ █▄█ █▀█%s\n' "$C_T" "$C_0"
    printf '%s   %s%s\n' "$C_D" "${1:-}" "$C_0"
    printf '%s└─%*s─┘%s\n' "$C_A" $((w - 4)) "" "$C_0"
}

UI_STEP=0
UI_STEPS=0
ui_step() {     # ui_step "TITLE"
    UI_STEP=$((UI_STEP + 1))
    printf '\n%s%s ▸ %02d/%02d %s%s%s  %s%s\n' "$C_A" "$C_B" "$UI_STEP" "$UI_STEPS" "$C_0" "$C_T$C_B" "$1" "$C_L" "$C_0"
}

ui_ok()   { printf '   %s✓%s %s\n' "$C_A" "$C_0" "$*"; }
ui_warn() { printf '   %s!%s %s\n' "$C_A2" "$C_0" "$*"; }
ui_info() { printf '   %s· %s%s\n' "$C_D" "$*" "$C_0"; }
ui_err()  { printf '   %s✗ %s%s\n' "$C_E" "$*" "$C_0" >&2; }
ui_die()  { ui_err "$*"; exit 1; }
ui_cmd()  { printf '     %s$ %s%s\n' "$C_A2" "$*" "$C_0"; }    # shows a command before running it
ui_text() { printf '   %s%s%s\n' "$C_T" "$*" "$C_0"; }

# Yes/no. ui_confirm "Question?" [yes|no default]
ui_confirm() {
    local def="${2:-yes}" r
    [ "${AUTO_YES:-0}" = 1 ] && return 0
    if [ "$USE_GUM" = 1 ]; then
        local extra=(); [ "$def" = no ] && extra=(--default=false)
        gum confirm "${extra[@]}" --affirmative "${T[yes]}" --negative "${T[no]}" "$1"
        return
    fi
    local hint="[Y/n]"; [ "$def" = no ] && hint="[y/N]"
    read -rp "   ${C_A}?${C_0} $1 $hint " r
    r="${r:-$([ "$def" = yes ] && echo y || echo n)}"
    [[ "${r,,}" =~ ^(y|yes|s|si|sí)$ ]]
}

# Free text. ui_input "Question" "default" -> stdout. Returns 1 on Esc / "<" (= go back)
ui_input() {
    local r
    if [ "${AUTO_YES:-0}" = 1 ]; then printf '%s' "$2"; return; fi
    if [ "$USE_GUM" = 1 ]; then
        r="$(gum input --header "$1" --value "$2" --width 60)" || return 1
    else
        read -rp "   ${C_A}?${C_0} $1 ${C_D}[$2]${C_0} " r
        [ "$r" = "<" ] && return 1
    fi
    printf '%s' "${r:-$2}"
}

# Pick one. ui_choose "Question" "default value" "value|label" ... -> value on stdout, 1 on Esc
ui_choose() {
    local q="$1" def="$2"; shift 2
    local -a vals=() labels=(); local o i r
    for o in "$@"; do vals+=("${o%%|*}"); labels+=("${o#*|}"); done
    if [ "${AUTO_YES:-0}" = 1 ]; then printf '%s' "$def"; return; fi
    if [ "$USE_GUM" = 1 ]; then
        local sel=""
        for i in "${!vals[@]}"; do [ "${vals[$i]}" = "$def" ] && sel="${labels[$i]}"; done
        r="$(printf '%s\n' "${labels[@]}" | gum choose --header "$q" ${sel:+--selected "$sel"})" || return 1
        for i in "${!labels[@]}"; do [ "${labels[$i]}" = "$r" ] && { printf '%s' "${vals[$i]}"; return; }; done
        printf '%s' "$def"; return
    fi
    printf '   %s?%s %s\n' "$C_A" "$C_0" "$q" >&2
    for i in "${!labels[@]}"; do
        local mark=" "; [ "${vals[$i]}" = "$def" ] && mark="${C_A}▸${C_0}"
        printf '   %s %2d  %s\n' "$mark" $((i + 1)) "${labels[$i]}" >&2
    done
    read -rp "   ${C_D}[enter = ▸]${C_0} " r
    [ "$r" = "<" ] && return 1
    if [[ "$r" =~ ^[0-9]+$ ]] && [ "$r" -ge 1 ] && [ "$r" -le "${#vals[@]}" ]; then printf '%s' "${vals[$((r - 1))]}"
    else printf '%s' "$def"; fi
}

# Pick many. ui_multi "Question" "value|label|on" ... -> chosen values, one per line
ui_multi() {
    local q="$1"; shift
    local -a vals=() labels=() on=(); local o i r n
    for o in "$@"; do
        local v l s; IFS="|" read -r v l s <<<"$o"; vals+=("$v"); labels+=("$l"); on+=("${s:-0}")
    done
    if [ "${AUTO_YES:-0}" = 1 ]; then
        for i in "${!vals[@]}"; do [ "${on[$i]}" = 1 ] && echo "${vals[$i]}"; done; return
    fi
    if [ "$USE_GUM" = 1 ]; then
        local sel=()
        for i in "${!vals[@]}"; do [ "${on[$i]}" = 1 ] && sel+=(--selected "${labels[$i]}"); done
        r="$(printf '%s\n' "${labels[@]}" | gum choose --no-limit --header "$q" "${sel[@]}")" || return 1
        while IFS= read -r o; do
            for i in "${!labels[@]}"; do [ "${labels[$i]}" = "$o" ] && echo "${vals[$i]}"; done
        done <<<"$r"
        return
    fi
    while true; do
        printf '   %s?%s %s\n' "$C_A" "$C_0" "$q" >&2
        for i in "${!vals[@]}"; do
            local box="□"; [ "${on[$i]}" = 1 ] && box="${C_A}■${C_0}"
            printf '   %2d %s %s\n' $((i + 1)) "$box" "${labels[$i]}" >&2
        done
        read -rp "   ${C_D}${T[plain_toggle]}${C_0} " r
        [ "$r" = "<" ] && return 1
        [ -z "$r" ] && break
        for n in $r; do
            [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#vals[@]}" ] || continue
            i=$((n - 1)); on[$i]=$((1 - on[$i]))
        done
    done
    for i in "${!vals[@]}"; do [ "${on[$i]}" = 1 ] && echo "${vals[$i]}"; done
}

# Runs a command with a spinner (gum) or just runs it
ui_spin() {     # ui_spin "title" cmd args...
    local title="$1"; shift
    if [ "$USE_GUM" = 1 ]; then gum spin --title "$title" -- "$@"
    else ui_info "$title"; "$@"; fi
}
