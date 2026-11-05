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
    for k in $(setting_keys) LOCK_SECONDS SCREEN_OFF_SECONDS; do
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

# place <src> <dst>: renders src into dst. If dst is yours (not ours), it's backed up first.
PLACED=0 BACKED=0
place() {
    local src="$1" dst="$2" new; new="$(mktemp)"
    render "$src" > "$new"
    [ -x "$src" ] && chmod +x "$new"
    if [ -e "$dst" ] && cmp -s "$new" "$dst"; then rm -f "$new"; mark_managed "$dst"; return; fi

    local backup=""
    if { [ -e "$dst" ] || [ -L "$dst" ]; } && ! is_managed "$dst"; then
        backup="$STATE/backups/$SESSION${dst#"$HOME"}"
        BACKED=$((BACKED + 1))
    fi

    if [ "${DRY_RUN:-0}" = 1 ]; then
        ui_info "→ ${dst/#$HOME/\~}${backup:+  (${T[backup_will]})}"
        rm -f "$new"; return
    fi
    if [ -n "$backup" ]; then
        mkdir -p "$(dirname "$backup")" && mv "$dst" "$backup"
        printf '%s\t%s\n' "$dst" "$backup" >> "$STATE/backups.list"
    fi
    mkdir -p "$(dirname "$dst")"
    mv "$new" "$dst"
    PLACED=$((PLACED + 1))
    mark_managed "$dst"
}

mark_managed() {
    [ "${DRY_RUN:-0}" = 1 ] && return
    mkdir -p "$STATE"
    is_managed "$1" || printf '%s\n' "$1" >> "$STATE/managed.list"
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

# ── reload everything that's running ─────────
reload_desktop() {
    [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || return 0
    hyprctl reload >/dev/null 2>&1
    # waybar: the autostart loop brings it back by itself
    pkill -x waybar
    # ...unless you started waybar some other way, then we do it
    ( sleep 3; pgrep -x waybar >/dev/null || setsid -f waybar >/dev/null 2>&1 ) &
    if pgrep -x hypridle >/dev/null; then
        if systemctl --user -q is-active hypridle 2>/dev/null; then systemctl --user restart hypridle
        else pkill -x hypridle; setsid -f hypridle >/dev/null 2>&1; fi
    fi
    pkill -x dunst 2>/dev/null       # dbus starts it again on the next notification
    pkill -USR1 -x kitty 2>/dev/null
}
