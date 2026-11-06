# btop: point it at the automata theme (matugen writes it). btop.conf is btop's own file and it
# rewrites it on exit, so only the theme lines get touched. Uninstall doesn't need to undo this:
# with the theme file gone, btop falls back to its default
conf="$HOME/.config/btop/btop.conf"
mkdir -p "${conf%/*}"
if [ -f "$conf" ]; then
    sed -i -e 's/^color_theme = .*/color_theme = "automata"/' -e 's/^theme_background = .*/theme_background = False/' "$conf"
    grep -q '^color_theme' "$conf" || printf 'color_theme = "automata"\n' >> "$conf"
else
    printf 'color_theme = "automata"\ntheme_background = False\n' > "$conf"
fi
