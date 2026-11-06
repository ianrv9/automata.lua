<div align="center">

<img src="assets/logo.svg" width="110" alt="automata.lua">

# automata.lua

A Hyprland rice with a HUD look. It takes the colors from your wallpaper and applies them to the whole desktop.

![Hyprland 0.55+](https://img.shields.io/badge/Hyprland-0.55%2B-b6c4ff?style=flat-square)
![Arch](https://img.shields.io/badge/Arch-based-b6c4ff?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-b6c4ff?style=flat-square)

[Español](README.es.md)

</div>

| Desktop | Launcher + wallpaper picker | Lock screen |
|:---:|:---:|:---:|
| ![](assets/desktop.jpg) | ![](assets/launcher.jpg) | ![](assets/lock.jpg) |
| **Discord (Vesktop)** | **Firefox** | **Spotify** |
| ![](assets/vesktop.jpg) | ![](assets/firefox.jpg) | ![](assets/spotify.jpg) |
| **Obsidian** | | |
| ![](assets/obsidian.jpg) | | |

## What it is

The config for my own desktop, cleaned up so anyone can install it. It has:

- Configs for Hyprland, the bar, terminal, launcher, notifications, lock screen and login screen,
  plus themes for Discord (Vesktop), Firefox, Obsidian and Spotify.
- An installer that asks what you want before touching anything.
- A settings menu (`automata`) to change things later without editing files.

When you change the wallpaper (an image or a video), [matugen](https://github.com/InioX/matugen)
makes a palette from it and every app above reloads with the new colors. Nothing needs a restart.

The look: thin frames with corner brackets, almost square corners, Space Grotesk and JetBrains Mono.

## Compatibility

| | |
|---|---|
| **Distro** | Arch and Arch-based (EndeavourOS, CachyOS, Manjaro…). On other distros you'd have to install the packages yourself |
| **Hyprland** | 0.55 or newer (it uses the Lua config). Last tested on 0.57 |
| **Tested on** | EndeavourOS, AMD GPU, desktop PC, one monitor |
| **Laptops** | The battery shows up in the bar and the brightness keys work |
| **NVIDIA** | Detected, and the env vars from the Hyprland wiki get set. Not tested on real hardware |
| **Several monitors / HiDPI** | `automata` → Monitors |
| **Shells** | bash, zsh and fish |

## Modules

You choose which ones to install. Apps you already have come pre-selected.

| Module | What it does |
|---|---|
| **Hyprland** | Window manager: borders, animations, blur, keybinds, lock screen (hyprlock), idle (hypridle) |
| **Waybar** | Bar: workspaces, active window, clock, music, CPU/RAM/temperature, battery, audio, network, power menu |
| **Rofi** | App launcher, wallpaper picker with thumbnails, clipboard history, power menu |
| **Kitty** | Terminal |
| **Dunst** | Notifications |
| **GTK** | Colors for GTK 3/4 apps (Thunar, settings…) |
| **Shell** | Prompt, `ls` with icons (eza), `cd` with zoxide, history search with fzf, fastfetch with the automata logo |
| **Vesktop** | Discord theme, based on [Midnight](https://github.com/refact0r/midnight-discord) |
| **Firefox** | Interface theme, your wallpaper on the new tab page, live colors through Pywalfox |
| **Obsidian** | CSS snippet for your vault |
| **Spotify** | Spicetify theme. Colors change live, without running `spicetify apply` each time |
| **SDDM** | Login screen. Needs sudo, and shows the exact commands first |

## Install

```bash
git clone https://github.com/ianrv9/automata.lua
cd automata.lua
./install
```

The installer goes through these steps:

1. **Language**: English or Spanish. It applies to the desktop too (bar, menus, lock screen).
2. **Modules**: which ones to install.
3. **Setup**: *Quick* uses the defaults. *Custom* asks about terminal, file manager, browser,
   keyboard layout, wallpaper folder, color style, look, bar position, lock times and fonts.
4. **Your previous Hyprland config**, if there is one: keybinds, monitors, env vars and startup
   programs get copied into `~/.config/hypr/personal.lua`. Keybinds that clash with automata's are
   left commented out.
5. **Packages**: lists what's missing and shows the install command before running it.
6. **Plan**: lists which of your files will be replaced. Nothing has changed up to this point.
7. **Install**: copies the files, backs up the ones it replaces and generates the colors.
   It starts with the official wallpaper *Unit 01 · Ash*.
8. **Extras**: Firefox profile, Spotify, login screen. Each one asks first.

`./install --dry-run` goes through all of it without changing anything, so you can see what it would do.

Replaced files are backed up in `~/.local/state/automata/backups/`. `automata uninstall` puts them back.

## Official wallpapers

Three wallpapers come with automata. Each one gives a different palette, so they're a quick way to
see how the colors change. They always show up in the picker (**Super + W**), after your own.

| Unit 01 · Ash | Unit 02 · Tide | Unit 03 · Ember |
|:---:|:---:|:---:|
| ![](wallpapers/automata-ash.jpg) | ![](wallpapers/automata-tide.jpg) | ![](wallpapers/automata-ember.jpg) |

They're generated with `tools/make-wallpaper.sh`, which can make more in other colors.

## Settings

Run `automata`:

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

Changes apply right away. They're saved in `~/.config/automata/settings.conf`, which you can also
edit by hand and then run `automata apply`:

| Setting | What it does | Default |
|---|---|---|
| `LANGUAGE` | `en` or `es` | your system's |
| `WALLPAPER_DIR` | your wallpaper folder | `~/Pictures/Wallpapers` |
| `COLOR_SCHEME` | how the palette is made: `scheme-content`, `scheme-tonal-spot`, `scheme-vibrant`, `scheme-expressive`, `scheme-monochrome` | `scheme-content` |
| `TERMINAL` / `FILE_MANAGER` / `BROWSER` | what Super + Q / E / B open | kitty / thunar / firefox |
| `KB_LAYOUT` / `KB_VARIANT` | keyboard layout | the one you use now |
| `GAPS_IN` / `GAPS_OUT` | space between windows / around the screen | 6 / 14 |
| `BORDER_SIZE` / `ROUNDING` | border thickness / corner rounding | 2 / 4 |
| `BLUR` | blur behind the bar, menus and terminal | yes |
| `ANIMATIONS` | `fast`, `relaxed` or `off` | fast |
| `INACTIVE_OPACITY` | opacity of unfocused windows | 0.94 |
| `BAR_POSITION` | `top` or `bottom` | top |
| `FONT_UI` / `FONT_MONO` | fonts | Space Grotesk / JetBrainsMono Nerd Font |
| `LOCK_AFTER` / `SCREEN_OFF_AFTER` | idle minutes, `0` = never | 10 / 11 |
| `MONITORS` | mode, position and scale per monitor (the menu fills it in) | automatic |
| `GPU` | `nvidia` adds NVIDIA's env vars | detected |

### Your own changes

- **Hyprland** (monitors, keybinds, startup programs): `~/.config/hypr/personal.lua`. It loads last,
  so it overrides everything else, and updates don't touch it.
- **Extra matugen templates**: `~/.config/automata/matugen-extra.toml`.
- **Anything else**: the files automata installs get rewritten on every apply. If you edit one by hand,
  automata keeps a copy of your version in the backups and tells you where. To change a module for
  good, fork the repo and edit `modules/<name>/`.

## Keybinds

| Keys | Action |
|---|---|
| `Super + Q` | Terminal |
| `Super + R` | App launcher |
| `Super + E` | File manager |
| `Super + B` | Browser |
| `Super + W` | Wallpaper picker |
| `Super + C` | Close window |
| `Super + V` | Float / unfloat window |
| `Super + P` | Pseudo-tile |
| `Super + J` | Toggle split direction |
| `Super + arrows` | Move focus |
| `Super + 1…0` | Go to workspace |
| `Super + Shift + 1…0` | Move window to workspace |
| `Super + mouse wheel` | Next / previous workspace |
| `Super + S` / `Super + Alt + S` | Show scratchpad / send window to it |
| `Super + Shift + S` or `Print` | Screenshot of a region (opens swappy) |
| `Super + Shift + V` | Clipboard history |
| `Super + L` | Lock |
| `Super + Delete` | Turn the screen off |
| `Super + M` | Log out (asks first) |
| `Super + left / right drag` | Move / resize window |

Media, volume and brightness keys work as expected.

## Updating

```bash
cd automata.lua && git pull && ./install
```

If automata is already installed, the installer asks what to do:

- **Update, keep the current settings**: no questions.
- **Change one part of the settings**: then either apply only that, or continue the setup from there.
- **Set everything up again**.

`settings.conf` and `personal.lua` are kept.

## Uninstall

```bash
automata uninstall
```

Restores your previous files and removes what automata added. Installed packages stay.

## How it works

```
 wallpaper ──► change-wallpaper ──► matugen ──► templates ──► colors.css, colors.lua, …
     │                                                              │
     └──► mpvpaper (shows it, videos too)        each app reloads its colors file
```

- matugen fills in one template per app. Waybar, kitty, dunst, Hyprland, Obsidian and Vesktop reload
  those files on their own. Spotify has a small script that checks for new colors every 2 seconds,
  and Firefox goes through Pywalfox.
- The installer (`bin/automata`) is bash. Each folder in `modules/` is a module:

  ```
  modules/waybar/
  ├── module.conf    name, description, packages, dependencies
  ├── home/          files copied into your $HOME
  ├── templates/     matugen templates
  ├── matugen.toml   which template makes which file
  └── post.sh        optional extra steps
  ```

  Files can use `@@SETTING@@` and `@@t:text@@` placeholders, which get replaced with your settings
  and the chosen language on install. Adding a module means adding a folder.

## Problems

See [docs/troubleshooting.md](docs/troubleshooting.md). If it's not there, open an issue with the
output of `automata info`.

Hyprland, Discord and Firefox change often. `automata info` shows the Hyprland version this was last
tested on, and the installer warns you if yours is newer.

## Credits

- [matugen](https://github.com/InioX/matugen) for the palettes.
- [Midnight](https://github.com/refact0r/midnight-discord) by refact0r, the base of the Vesktop theme.
- [gum](https://github.com/charmbracelet/gum) for the installer menus.
- Fonts: [Space Grotesk](https://github.com/floriankarsten/space-grotesk), [JetBrains Mono Nerd Font](https://www.nerdfonts.com/).

MIT © Calternar
