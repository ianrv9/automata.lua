# Troubleshooting

[Español](troubleshooting.es.md)

## Hyprland crashes right after logging in (mostly the first time after boot)

Hyprland 0.57 asks for realtime priority. If that first start is slow (cold cache, lots of apps),
the kernel kills it for hogging realtime CPU and you land in safe mode.

Add this to `~/.bash_profile` (or wherever you set your session's environment) and reboot:

```bash
export HYPRLAND_NO_RT=1
```

Check it worked: `chrt -p $(pgrep -x Hyprland)` should say `SCHED_OTHER`.

## Screen turns off → Hyprland or apps crash ("Oopsie daisy")

Some monitors (mostly over HDMI) disconnect when they go to sleep, and Hyprland 0.57 can crash when
that happens. The fix is to tell the kernel the connector is always connected.

1. Find the connector name: `hyprctl monitors` (e.g. `HDMI-A-1`).
2. Add `video=HDMI-A-1:e` to your kernel parameters (systemd-boot: `/etc/kernel/cmdline`,
   GRUB: `GRUB_CMDLINE_LINUX` in `/etc/default/grub`) and regenerate your boot config.
3. If the monitor wakes up at the wrong resolution, you also need to load its EDID from a file
   (`drm.edid_firmware=HDMI-A-1:edid/your-monitor.bin`). Search "edid_firmware" on the Arch Wiki.

Meanwhile: `automata` → Lock and screen off → set the screen-off time to `0`.

## Spotify lost the theme after an update

```bash
spicetify backup apply
```

If it says "Preprocessed data outdated": `spicetify restore backup apply`.

## Spotify menus have a weird blurry square behind them

Spotify runs on XWayland by default. The module installs `~/.config/spotify-flags.conf` so it
runs on native Wayland. If you launch it some other way (flatpak…), pass it the same flags.

## Vesktop theme does nothing

Vesktop → Settings → Themes → enable `automata`. After that colors follow the wallpaper by themselves.

## Firefox didn't change

1. Open Firefox at least once (so it makes your profile), then run `firefox-hud --install`.
2. Close Firefox **completely** and open it again.
3. For live colors, install the [Pywalfox](https://addons.mozilla.org/firefox/addon/pywalfox/) extension.

## I edited a config file and my change disappeared

The files automata installs get rewritten on every `automata apply` and every time you change
something in the menu. Your edited version isn't lost: automata copies it to
`~/.local/state/automata/backups/<date>/edited/` and prints the path when it happens.

To keep changes, put them where automata doesn't write:

- Hyprland: `~/.config/hypr/personal.lua`
- Extra matugen templates: `~/.config/automata/matugen-extra.toml`
- Settings that are in the menu: `automata`

Or fork the repo and change the module.

## Something else

Open an issue with what you did, what happened and the output of `automata info`. Useful logs:
`$XDG_RUNTIME_DIR/hypr/*/hyprland.log` (Hyprland) and `~/.cache/automata/mpvpaper.log` (wallpaper).
