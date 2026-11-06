# Everything that isn't UI: settings, modules, rendering, backups.
# Sourced by bin/automata. Expects $SRC to point at the repo (or its installed copy).

SHARE="$HOME/.local/share/automata"      # installed copy of the repo, so `automata` works even if you delete the clone
CONF="$HOME/.config/automata"
STATE="$HOME/.local/state/automata"
SETTINGS="$CONF/settings.conf"
HYPR_MIN="0.55"

# ── settings ─────────────────────────────────
load_settings() {
    . "$SRC/defaults.conf"
    [ -f "$SETTINGS" ] && . "$SETTINGS"
    load_lang "${LANGUAGE:-en}"
}

load_lang() {
    local f="$SRC/lang/$1.sh"
    [ -f "$f" ] || f="$SRC/lang/en.sh"
    . "$f"
}

# All setting keys, straight from defaults.conf
setting_keys() { grep -oE '^[A-Z_]+=' "$SRC/defaults.conf" | tr -d '='; }

save_settings() {
    [ "${DRY_RUN:-0}" = 1 ] && return
    mkdir -p "$CONF"
    local k tmp; tmp="$(mktemp)"
    # Rewrite defaults.conf with your values, so the comments stay where they are
    while IFS= read -r line; do
        if [[ "$line" =~ ^([A-Z_]+)= ]]; then
            k="${BASH_REMATCH[1]}"
            local rest="" ; [[ "$line" =~ \"[[:space:]]+(#.*)$ ]] && rest="  ${BASH_REMATCH[1]}"
            printf '%s="%s"%s\n' "$k" "${!k//\"/\\\"}" "$rest"
        else
            printf '%s\n' "$line"
        fi
    done < "$SRC/defaults.conf" > "$tmp"
    mv "$tmp" "$SETTINGS"
}

set_setting() { printf -v "$1" '%s' "$2"; }

# ── modules ──────────────────────────────────
modules_all() { local d; for d in "$SRC"/modules/*/; do basename "$d"; done; }
module_exists() { [ -f "$SRC/modules/$1/module.conf" ]; }

# module_get <module> <FIELD>   (DESC is picked in your language)
module_get() {
    ( NAME="" DESC_en="" DESC_es="" REQUIRES="" PACKAGES="" AUR="" OPTIONAL="" ALWAYS="" DETECT=""
      . "$SRC/modules/$1/module.conf"
      if [ "$2" = DESC ]; then local v="DESC_${LANGUAGE:-en}"; printf '%s' "${!v:-$DESC_en}"
      else printf '%s' "${!2}"; fi )
}

modules_installed() { cat "$CONF/modules" 2>/dev/null; }
is_installed() { grep -qx "$1" "$CONF/modules" 2>/dev/null; }

# Should this module be ticked in the menu?
module_default() {
    is_installed "$1" && return 0
    [ "$(module_get "$1" OPTIONAL)" = 1 ] || return 0
    local detect; detect="$(module_get "$1" DETECT)"
    [ -n "$detect" ] && eval "$detect" >/dev/null 2>&1
}

# Adds dependencies (REQUIRES) and the always-on ones, core goes first
modules_resolve() {
    local -A seen=(); local out=() todo=($1) m r
    for m in $(modules_all); do [ "$(module_get "$m" ALWAYS)" = 1 ] && todo+=("$m"); done
    while [ ${#todo[@]} -gt 0 ]; do
        m="${todo[0]}"; todo=("${todo[@]:1}")
        [ -n "${seen[$m]:-}" ] && continue
        module_exists "$m" || ui_die "${T[no_module]} $m"
        seen[$m]=1; out+=("$m")
        for r in $(module_get "$m" REQUIRES); do todo+=("$r"); done
    done
    printf '%s\n' "${out[@]}" | sort | awk '$0=="core"{print; next} {r=r $0 "\n"} END{printf "%s", r}'
}

# ── rendering ────────────────────────────────
# Files can have @@SETTING@@ and @@t:key@@ in them. This builds one sed script with all of it.
RENDER_SED=""
build_render() {
    RENDER_SED="$(mktemp)"
    local k v esc
    LOCK_SECONDS=$(( LOCK_AFTER > 0 ? LOCK_AFTER * 60 : 99999999 ))          # "never" = in about 3 years
    SCREEN_OFF_SECONDS=$(( SCREEN_OFF_AFTER > 0 ? SCREEN_OFF_AFTER * 60 : 99999999 ))
    # dates in the bar follow LANGUAGE, not the system locale. Any installed locale of that language
    # will do (es_ES missing but es_MX there? fine)
    TIME_LOCALE="$(locale -a 2>/dev/null | grep -m1 -ix "${T[ui_locale]%%.*}\.utf-\?8")"
    [ -n "$TIME_LOCALE" ] || TIME_LOCALE="$(locale -a 2>/dev/null | grep -m1 -i "^${LANGUAGE}_.*utf")"
    : "${TIME_LOCALE:=C.UTF-8}"
    for k in $(setting_keys) LOCK_SECONDS SCREEN_OFF_SECONDS TIME_LOCALE; do
        v="${!k}"; esc="$(printf '%s' "$v" | sed 's/[\\|&]/\\&/g')"
        printf 's|@@%s@@|%s|g\n' "$k" "$esc"
    done > "$RENDER_SED"
    for k in "${!T[@]}"; do
        [[ "$k" == ui_* ]] || continue
        esc="$(printf '%s' "${T[$k]}" | sed 's/[\\|&]/\\&/g')"
        printf 's|@@t:%s@@|%s|g\n' "${k#ui_}" "$esc"
    done >> "$RENDER_SED"
}

render() {      # render <src> -> stdout
    if grep -q '@@' "$1"; then sed -f "$RENDER_SED" "$1"; else cat "$1"; fi
}

# ── placing files ────────────────────────────
is_managed() { grep -qxF "$1" "$STATE/managed.list" 2>/dev/null; }

# place <src> <dst>: renders src into dst.
#  - dst is yours (automata never placed it): moved to backups, uninstall puts it back
#  - dst is automata's but you edited it since: a copy of your version is kept, and you get told
#  - dst is automata's and untouched: just overwritten
PLACED=0 BACKED=0
place() {
    local src="$1" dst="$2" new; new="$(mktemp)"
    render "$src" > "$new"
    [ -x "$src" ] && chmod +x "$new"
    if [ -e "$dst" ] && cmp -s "$new" "$dst"; then rm -f "$new"; mark_managed "$dst"; return; fi

    local backup="" edited=""
    if { [ -e "$dst" ] || [ -L "$dst" ]; } && ! is_managed "$dst"; then
        backup="$STATE/backups/$SESSION${dst#"$HOME"}"
        BACKED=$((BACKED + 1))
    elif [ -e "$dst" ] && was_edited "$dst"; then
        edited="$STATE/backups/$SESSION/edited${dst#"$HOME"}"
    fi

    if [ "${DRY_RUN:-0}" = 1 ]; then
        ui_info "→ ${dst/#$HOME/\~}${backup:+  (${T[backup_will]})}${edited:+  (${T[edited_kept]} ${edited/#$HOME/\~})}"
        rm -f "$new"; return
    fi
    if [ -n "$backup" ]; then
        mkdir -p "$(dirname "$backup")" && mv "$dst" "$backup"
        printf '%s\t%s\n' "$dst" "$backup" >> "$STATE/backups.list"
    fi
    if [ -n "$edited" ]; then
        mkdir -p "$(dirname "$edited")" && cp -p "$dst" "$edited"
        ui_warn "${dst/#$HOME/\~} ${T[edited_kept]} ${edited/#$HOME/\~}"
    fi
    mkdir -p "$(dirname "$dst")"
    mv "$new" "$dst"
    PLACED=$((PLACED + 1))
    mark_managed "$dst"
}

# Every file placed gets its checksum written down, that's how hand edits get noticed
file_sum() { sha1sum "$1" 2>/dev/null | cut -d' ' -f1; }
was_edited() {
    local known; known="$(awk -v f="$1" '$2==f{s=$1} END{print s}' "$STATE/managed.sum" 2>/dev/null)"
    [ -n "$known" ] && [ "$known" != "$(file_sum "$1")" ]
}

mark_managed() {
    [ "${DRY_RUN:-0}" = 1 ] && return
    mkdir -p "$STATE"
    is_managed "$1" || printf '%s\n' "$1" >> "$STATE/managed.list"
    { grep -vF "  $1" "$STATE/managed.sum" 2>/dev/null; printf '%s  %s\n' "$(file_sum "$1")" "$1"; } > "$STATE/managed.sum.tmp"
    mv "$STATE/managed.sum.tmp" "$STATE/managed.sum"
}

# Where a module's files end up, one path per line (same mapping as place_module)
module_targets() {
    local dir="$SRC/modules/$1" f
    [ -d "$dir/home" ] && find "$dir/home" -type f | sed "s|^$dir/home/|$HOME/|"
    [ -d "$dir/templates" ] && for f in "$dir"/templates/*; do echo "$HOME/.config/matugen/templates/$(basename "$f")"; done
    return 0
}

# Files an older version placed that no version places anymore (renamed, moved, dropped).
# They go away, or back to your original if they replaced one.
prune_stale() {
    [ "${DRY_RUN:-0}" = 1 ] && return
    [ -f "$STATE/managed.list" ] || return 0
    local wanted m f; wanted="$(mktemp)"
    { for m in $1; do module_targets "$m"; done; echo "$HOME/.config/matugen/config.toml"; } | sort -u > "$wanted"
    while IFS= read -r f; do
        grep -qxF "$f" "$wanted" || restore_file "$f"
    done < <(cat "$STATE/managed.list")
    rm -f "$wanted"
}

# Deletes one of automata's files and puts yours back if there was one
restore_file() {
    local dst="$1" backup
    is_managed "$dst" || return 0
    rm -f "$dst"
    backup="$(awk -F'\t' -v d="$dst" '$1==d{b=$2} END{print b}' "$STATE/backups.list" 2>/dev/null)"
    if [ -n "$backup" ] && [ -e "$backup" ]; then mkdir -p "$(dirname "$dst")"; mv "$backup" "$dst"; fi
    grep -vxF "$dst" "$STATE/managed.list" > "$STATE/managed.tmp"; mv "$STATE/managed.tmp" "$STATE/managed.list"
}

place_module() {
    local m="$1" dir="$SRC/modules/$1" f
    if [ -d "$dir/home" ]; then
        while IFS= read -r -d '' f; do
            place "$f" "$HOME/${f#"$dir/home/"}"
        done < <(find "$dir/home" -type f -print0 | sort -z)
    fi
    if [ -d "$dir/templates" ]; then
        for f in "$dir"/templates/*; do place "$f" "$HOME/.config/matugen/templates/$(basename "$f")"; done
    fi
}

# ── matugen ──────────────────────────────────
# Glues every installed module's matugen.toml into one config (+ yours from matugen-extra.toml)
build_matugen() {
    local tmp m; tmp="$(mktemp)"
    {
        echo "# Made by automata.lua, rebuilt on every 'automata apply'."
        echo "# Your own templates go in ~/.config/automata/matugen-extra.toml"
        echo
        echo "[config]"
        for m in $1; do
            [ -f "$SRC/modules/$m/matugen.toml" ] || continue
            [ "$m" = obsidian ] && [ -z "${OBSIDIAN_VAULT:-}" ] && continue
            [ "$m" = spotify ] && [ -z "${SPOTIFY_PATH:-}" ] && continue
            # only once the sudo part of the sddm module actually happened
            [ "$m" = sddm ] && [ ! -w /usr/share/sddm/themes/automata/theme.conf.user ] && continue
            printf '\n# ── %s\n' "$m"
            sed -e "s|@@VAULT@@|${OBSIDIAN_VAULT:-}|g" -e "s|@@SPOTIFY@@|${SPOTIFY_PATH:-}|g" "$SRC/modules/$m/matugen.toml"
        done
        [ -f "$CONF/matugen-extra.toml" ] && { printf '\n# ── extra\n'; cat "$CONF/matugen-extra.toml"; }
    } > "$tmp"
    place "$tmp" "$HOME/.config/matugen/config.toml"
    rm -f "$tmp"
}

# ── system checks ────────────────────────────
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

hypr_version() { Hyprland --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1; }

missing_pkgs() { [ -n "$1" ] && command -v pacman >/dev/null && pacman -T $1 2>/dev/null | xargs; }

aur_helper() { local h; for h in paru yay; do command -v $h >/dev/null && { echo $h; return; }; done; }

# Obsidian lists its vaults in its own config, no need to go digging through $HOME
OBSIDIAN_CONFIGS=("$HOME/.config/obsidian/obsidian.json" "$HOME/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json")   # normal, flatpak
find_vault() { grep -ohE '"path":"[^"]+"' "${OBSIDIAN_CONFIGS[@]}" 2>/dev/null | head -1 | cut -d'"' -f4; }

find_spotify() {
    local d
    for d in /opt/spotify /usr/share/spotify /usr/lib/spotify \
             "$HOME/.local/share/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify" \
             /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify; do
        [ -d "$d/Apps" ] && { printf '%s' "$d"; return; }
    done
}

# Runs something with sudo, but shows it first and asks
run_sudo() {    # run_sudo "why" cmd...
    ui_warn "$1"; shift
    ui_cmd "sudo $*"
    [ "${DRY_RUN:-0}" = 1 ] && return 0
    ui_confirm "${T[plan_go]}" || return 1
    sudo "$@"
}

# ── lines in your shell's rc file ────────────
# Everything automata adds lives between these two markers, so uninstall can take it out cleanly
RC_START="# >>> automata.lua >>>"
RC_END="# <<< automata.lua <<<"

rc_has() { grep -qxF "$2" "$1" 2>/dev/null; }    # rc_has <rc> <line>

rc_add() {      # rc_add <rc> <line>: puts the line inside automata's block (makes the block if needed)
    local rc="$1" line="$2"
    rc_has "$rc" "$line" && return 0
    [ "${DRY_RUN:-0}" = 1 ] && return 0
    touch "$rc"
    if ! grep -qxF "$RC_START" "$rc"; then
        printf '\n%s\n%s\n' "$RC_START" "$RC_END" >> "$rc"
    fi
    local tmp; tmp="$(mktemp)"
    awk -v end="$RC_END" -v l="$line" '$0==end{print l} {print}' "$rc" > "$tmp" && cat "$tmp" > "$rc"
    rm -f "$tmp"
}

rc_clean() {    # rc_clean <rc>: removes automata's block (and the old one-line style from v0.0)
    [ -f "$1" ] || return 0
    local tmp; tmp="$(mktemp)"
    awk -v s="$RC_START" -v e="$RC_END" '
        $0==s {skip=1; next}  $0==e {skip=0; next}
        $0=="# automata.lua" {old=1; next}  old {old=0; next}
        !skip' "$1" > "$tmp" && cat "$tmp" > "$1"
    rm -f "$tmp"
}

rc_clean_legacy() {     # only the pre-block style ("# automata.lua" + one line)
    [ -f "$1" ] && grep -qx '# automata.lua' "$1" || return 0
    local tmp; tmp="$(mktemp)"
    awk '$0=="# automata.lua" {skip=1; next} skip {skip=0; next} {print}' "$1" > "$tmp" && cat "$tmp" > "$1"
    rm -f "$tmp"
}

# Which rc files to touch: bash always, zsh if you use it. fish doesn't need one (conf.d)
user_rcs() {
    echo "$HOME/.bashrc"
    { [ -f "$HOME/.zshrc" ] || [[ "${SHELL:-}" == */zsh ]]; } && echo "$HOME/.zshrc"
}

# ── hardware + versions ──────────────────────
HYPR_TESTED="0.57"       # newest Hyprland this was actually run on

detect_gpu() {
    local v
    for v in /sys/class/drm/card*/device/vendor; do
        [ "$(cat "$v" 2>/dev/null)" = "0x10de" ] && { echo nvidia; return; }
    done
    echo other
}

# ── reload everything that's running ─────────
# After uninstall: what automata started goes away, the rest reloads with the old configs
stop_desktop() {
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || return 0
    pkill -f "while hyprctl version >/dev/null 2>&1; do waybar" 2>/dev/null    # the respawn loop first
    pkill -x waybar; pkill -x mpvpaper; pkill -x dunst
    pkill -USR1 -x kitty 2>/dev/null
    hyprctl reload >/dev/null 2>&1
}

reload_desktop() {
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || return 0
    hyprctl reload >/dev/null 2>&1
    # waybar: the autostart loop brings it back by itself
    pkill -x waybar
    # ...unless it had started waybar some other way, then this does it
    ( sleep 3; pgrep -x waybar >/dev/null || setsid -f waybar >/dev/null 2>&1 ) &
    if pgrep -x hypridle >/dev/null; then
        if systemctl --user -q is-active hypridle 2>/dev/null; then systemctl --user restart hypridle
        else pkill -x hypridle; setsid -f hypridle >/dev/null 2>&1; fi
    fi
    pkill -x dunst 2>/dev/null       # dbus starts it again on the next notification
    pkill -USR1 -x kitty 2>/dev/null
}
