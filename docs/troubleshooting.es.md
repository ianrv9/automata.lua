# Problemas conocidos

[English](troubleshooting.md)

## Hyprland se cierra justo al iniciar sesión (sobre todo la primera vez tras encender)

Hyprland 0.57 pide prioridad de tiempo real. Si ese primer arranque va lento (caché fría, muchas apps),
el kernel lo mata por pasarse del límite de CPU en tiempo real y caes en el modo seguro.

Agrega esto a `~/.bash_profile` (o donde definas las variables de tu sesión) y reinicia:

```bash
export HYPRLAND_NO_RT=1
```

Para comprobarlo: `chrt -p $(pgrep -x Hyprland)` debe decir `SCHED_OTHER`.

## Se apaga la pantalla → Hyprland o las apps se cierran ("Oopsie daisy")

Algunos monitores (sobre todo por HDMI) se desconectan al entrar en reposo, y Hyprland 0.57 puede
cerrarse cuando pasa. La solución es decirle al kernel que el conector siempre está conectado.

1. Busca el nombre del conector: `hyprctl monitors` (por ejemplo `HDMI-A-1`).
2. Agrega `video=HDMI-A-1:e` a los parámetros del kernel (systemd-boot: `/etc/kernel/cmdline`;
   GRUB: `GRUB_CMDLINE_LINUX` en `/etc/default/grub`) y regenera el arranque.
3. Si el monitor despierta con otra resolución, también hay que cargar su EDID desde un archivo
   (`drm.edid_firmware=HDMI-A-1:edid/tu-monitor.bin`). Busca "edid_firmware" en la Arch Wiki.

Mientras tanto: `automata` → Bloqueo y apagado de pantalla → pon el apagado en `0`.

## Spotify perdió el tema después de actualizarse

```bash
spicetify backup apply
```

Si dice "Preprocessed data outdated": `spicetify restore backup apply`.

## Los menús de Spotify tienen un cuadrado borroso detrás

Spotify corre en XWayland por defecto. El módulo instala `~/.config/spotify-flags.conf` para que
corra en Wayland nativo. Si lo abres de otra forma (flatpak…), pásale esas mismas opciones.

## El tema de Vesktop no hace nada

Vesktop → Ajustes → Temas → activa `automata`. Desde ahí los colores siguen al fondo solos.

## Firefox no cambió

1. Abre Firefox al menos una vez (para que cree tu perfil) y corre `firefox-hud --install`.
2. Cierra Firefox **del todo** y ábrelo otra vez.
3. Para los colores en vivo, instala la extensión [Pywalfox](https://addons.mozilla.org/firefox/addon/pywalfox/).

## Edité un archivo de config y mi cambio desapareció

Los archivos que instala automata se reescriben en cada `automata apply` y cada vez que cambias algo
en el menú. Tu versión editada no se pierde: automata la copia a
`~/.local/state/automata/backups/<fecha>/edited/` y muestra la ruta cuando pasa.

Para que tus cambios se queden, ponlos donde automata no escribe:

- Hyprland: `~/.config/hypr/personal.lua`
- Plantillas extra de matugen: `~/.config/automata/matugen-extra.toml`
- Ajustes que están en el menú: `automata`

O haz un fork del repo y cambia el módulo.

## Otra cosa

Abre un issue con qué hiciste, qué pasó y la salida de `automata info`. Logs útiles:
`$XDG_RUNTIME_DIR/hypr/*/hyprland.log` (Hyprland) y `~/.cache/automata/mpvpaper.log` (fondo).
