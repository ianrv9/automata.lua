<div align="center">

<img src="assets/logo.svg" width="110" alt="automata.lua">

# automata.lua

**A HUD-style Hyprland desktop that repaints itself from your wallpaper.**

Corner brackets, square edges, Space Grotesk, and every app following the colors, live.

![Hyprland 0.55+](https://img.shields.io/badge/Hyprland-0.55%2B-b6c4ff?style=flat-square)
![Arch](https://img.shields.io/badge/Arch-based-b6c4ff?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-b6c4ff?style=flat-square)

[🇪🇸 Leer en español](README.es.md)

<!-- assets/preview.gif: change the wallpaper with Super+W, watch everything recolor -->

</div>

---

## What is this?

These are **dotfiles**: the config files that decide how a Linux desktop looks and behaves.
This set turns [Hyprland](https://hypr.land) (a tiling window manager) into a full desktop with one idea behind it:

> **You pick a wallpaper, and the whole system dresses up to match.**

The bar, terminal, notifications, launcher, lock screen, login screen, Discord, Firefox, Obsidian and
Spotify all take their colors from your wallpaper (images *and* videos), and they change **on the spot**
without restarting anything. Everything shares the same look: thin frames, corner brackets like a HUD
and squared-off corners.

It comes with an installer that asks you things in plain words, and a settings menu (`automata`), so
**you never have to touch a config file** unless you want to.

### Who's it for?

- You use **Arch** (or something based on it: EndeavourOS, CachyOS, Manjaro…) and want to try Hyprland
  without spending a weekend setting it up.
- You already use Hyprland and want the wallpaper-colors magic, or just some of the pieces.
  Everything is split into modules, so take only what you like.
- You like poking around configs. Everything is commented for that, and adding your own module is just a folder.

**Not for:** non-Arch distros (it can work, but you'll install packages by hand), or Hyprland older
than 0.55. This uses the new Lua config.

### Compatibility

| | |
|---|---|
| **Tested on** | EndeavourOS · Hyprland 0.57 · AMD GPU · desktop, single monitor |
| **Laptops** | Battery shows up in the bar by itself; brightness keys work |
| **NVIDIA** | Detected automatically, gets the env vars Hyprland's wiki recommends. **Untested on real hardware**, reports welcome |
| **Several monitors / HiDPI** | `automata` → Monitors (mode, scale, position per monitor) |
| **Shells** | bash, zsh and fish |

## Previews

<!-- Drop screenshots in assets/ and they show up here -->
| Desktop | Launcher + wallpaper picker | Lock screen |
|:---:|:---:|:---:|
| ![](assets/desktop.png) | ![](assets/launcher.png) | ![](assets/lock.png) |
| **Discord (Vesktop)** | **Firefox** | **Spotify** |
| ![](assets/vesktop.png) | ![](assets/firefox.png) | ![](assets/spotify.png) |

## What's in the box

| Module | What you get |
|---|---|
| **Hyprland** | Window manager config: gradient borders, quick animations, blur, keybinds, lock screen, idle |
| **Waybar** | The bar: workspaces, active window, clock, music, CPU/RAM/temp, audio, network, power menu |
| **Rofi** | App launcher, wallpaper picker with thumbnails, clipboard history |
| **Kitty** | See-through terminal in the wallpaper's colors |
| **Dunst** | Notifications |
| **GTK** | GTK 3/4 apps (Thunar, settings…) in the same palette |
| **Shell** | Nicer bash: prompt, `ls` with icons, smart `cd`, fuzzy history, fastfetch |
| **Vesktop** | Discord, HUD style, translucent and readable on any wallpaper |
| **Firefox** | HUD interface, your wallpaper on the new tab page, live colors |
| **Obsidian** | CSS snippet for your vault that reloads by itself |
| **Spotify** | Spicetify theme that recolors **live**, no `spicetify apply` every time |
| **SDDM** | Login screen to match (needs sudo, it'll tell you exactly what it runs) |

## Install

```bash
git clone https://github.com/ianrv9/automata.lua
cd automata.lua
./install
```

That's it. The installer walks you through it:

1. **Language**: English or Spanish (all of it, the desktop too).
2. **Modules**: pick with the arrow keys. Apps you already have come pre-ticked.
3. **Setup**: *Quick* (sensible defaults) or *Custom* (terminal, file manager, browser, keyboard layout,
   wallpaper folder, color style, look, bar position, lock times, fonts).
4. **Your old Hyprland config** (if you have one): its keybinds, monitors, env vars and startup programs
   get imported into `personal.lua`, so nothing you set up is lost. Binds that clash with the theme's
   are left commented out for you to decide.
5. **Packages**: shows what's missing and offers to install it, showing the exact command first.
6. **Plan**: shows which of your files will be replaced. Nothing has been touched yet.
7. **Install**: copies everything, backs up whatever it replaces, generates your colors.
   No wallpapers yet? Three sample ones (made for this theme) get added.
8. **Last touches**: per-app bits (Firefox profile, Spotify, login screen), each one asks first.

> Paranoid? Same here. `./install --dry-run` goes through everything and shows what it *would* do, without changing a thing.

Every file it replaces is backed up in `~/.local/state/automata/backups/`, and `automata uninstall`
puts them all back.

## Changing stuff

Run **`automata`** in a terminal and pick what you want to change:

```
 ▸ Style: gaps, borders, blur, animations
   Apps: terminal, files, browser
   Keyboard layout
   Monitors: mode, scale, position
   Wallpaper and colors
   Bar
   Lock and screen off
   Fonts
   Language / Idioma
   Add or remove modules
   Uninstall and restore previous files
```

Changes apply right away. Under the hood they're saved in `~/.config/automata/settings.conf`,
a plain text file you can also edit by hand (then run `automata apply`):

| Setting | What it does | Default |
|---|---|---|
| `LANGUAGE` | `en` or `es`, for the whole desktop | your system's |
| `WALLPAPER_DIR` | where your wallpapers live | `~/Pictures/Wallpapers` |
| `COLOR_SCHEME` | how colors are picked: `scheme-content`, `scheme-tonal-spot`, `scheme-vibrant`, `scheme-expressive`, `scheme-monochrome` | `scheme-content` |
| `TERMINAL` / `FILE_MANAGER` / `BROWSER` | what opens with Super+Q / E / B | kitty / thunar / firefox |
| `KB_LAYOUT` / `KB_VARIANT` | keyboard layout | whatever you use now |
| `GAPS_IN` / `GAPS_OUT` | space between windows / around the screen | 6 / 14 |
| `BORDER_SIZE` / `ROUNDING` | border thickness / corner rounding | 2 / 4 |
| `BLUR` | blur behind the bar, menus and terminal | yes |
| `ANIMATIONS` | `fast`, `relaxed` or `off` | fast |
| `INACTIVE_OPACITY` | how see-through unfocused windows are | 0.94 |
| `BAR_POSITION` | `top` or `bottom` | top |
| `FONT_UI` / `FONT_MONO` | fonts | Space Grotesk / JetBrainsMono Nerd Font |
| `LOCK_AFTER` / `SCREEN_OFF_AFTER` | idle minutes, `0` = never | 10 / 11 |
| `MONITORS` | per-monitor mode, position and scale (the menu writes it) | everything automatic |
| `GPU` | `nvidia` adds NVIDIA's env vars | detected |

### Going further

- **Your own Hyprland stuff** (monitors, binds, autostart) goes in `~/.config/hypr/personal.lua`.
  Updates never touch it, and it loads last, so it wins over everything.
- **Your own matugen templates**: `~/.config/automata/matugen-extra.toml`.
- **Changing a module itself**: fork the repo, edit `modules/<name>/`, run `./install`.

## Keybinds

| Keys | Does |
|---|---|
| `Super + W` | Pick a wallpaper (everything repaints) |
| `Super + Q` | Terminal |
| `Super + R` | App launcher |
| `Super + E` | File manager |
| `Super + B` | Browser |
| `Super + C` | Close window |
| `Super + V` | Float / unfloat window |
| `Super + 1…0` | Go to workspace |
| `Super + Shift + 1…0` | Move window to workspace |
| `Super + S` / `Super + Alt + S` | Scratchpad / send window there |
| `Super + Shift + S` or `Print` | Screenshot a region (edit with swappy) |
| `Super + Shift + V` | Clipboard history |
| `Super + L` | Lock |
| `Super + Delete` | Turn the screen off |
| `Super + M` | Log out (asks first) |
| `Super + drag` | Move (left click) / resize (right click) |

## How it works (for the curious)

```
 wallpaper ──► change-wallpaper ──► matugen ──► templates ──► colors.css, colors.lua, …
     │                                                              │
     └──► mpvpaper (shows it, videos too)        every app reloads its colors file
```

- **[matugen](https://github.com/InioX/matugen)** pulls a Material You palette out of the wallpaper and fills
  in one template per app. Apps that can reload live (waybar, kitty, dunst, Hyprland, Obsidian, Vesktop)
  do it on their own. Spotify gets a tiny script that checks for new colors every 2 seconds. Firefox goes through Pywalfox.
- **The installer** (`bin/automata`) is plain bash. Each folder in `modules/` is a module:

  ```
  modules/waybar/
  ├── module.conf    name, description, packages, dependencies
  ├── home/          copied into your $HOME as-is (with your settings filled in)
  ├── templates/     matugen templates
  ├── matugen.toml   which template makes which file
  └── post.sh        optional extra steps
  ```

  Files can have `@@SETTING@@` and `@@t:text@@` placeholders. That's how one file serves both languages and all your settings.
  **Adding a module = adding a folder.**

## Updating

```bash
cd automata.lua && git pull && ./install
```

Your settings and `personal.lua` stay as they are.

## Uninstall

```bash
automata uninstall
```

Your old files come back, and what automata added goes away. Packages stay, since you might be using them.

## Something broke?

Check [docs/troubleshooting.md](docs/troubleshooting.md): login crash, monitor turning off,
Spotify updates, Firefox not changing… If it's not there, open an issue and paste the output of
`automata info` (versions of everything, it's what's needed to reproduce it).

Hyprland, Discord and Firefox change things on their side every few weeks. `automata info` says which
Hyprland version this was last tested on, and the installer warns you if yours is newer.

## Credits

- [matugen](https://github.com/InioX/matugen) does the color magic.
- The Vesktop theme sits on top of [Midnight](https://github.com/refact0r/midnight-discord) by refact0r.
- [gum](https://github.com/charmbracelet/gum) makes the installer pretty.
- Fonts: [Space Grotesk](https://github.com/floriankarsten/space-grotesk), [JetBrains Mono Nerd Font](https://www.nerdfonts.com/).

MIT © Calternar. Do whatever you want with it, just keep the name somewhere.
