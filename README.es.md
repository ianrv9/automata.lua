<div align="center">

<img src="assets/logo.svg" width="110" alt="automata.lua">

# automata.lua

**Un escritorio Hyprland estilo HUD que se repinta solo a partir de tu fondo de pantalla.**

Marcas de esquina, bordes rectos, Space Grotesk, y todas las apps siguiendo los colores en vivo.

![Hyprland 0.55+](https://img.shields.io/badge/Hyprland-0.55%2B-b6c4ff?style=flat-square)
![Arch](https://img.shields.io/badge/Arch-based-b6c4ff?style=flat-square)
![Licencia](https://img.shields.io/badge/licencia-MIT-b6c4ff?style=flat-square)

[🇺🇸 Read in English](README.md)

<!-- assets/preview.gif: cambiar el fondo con Super+W y ver cómo se repinta todo -->

</div>

---

## ¿Qué es esto?

Son **dotfiles**: los archivos de configuración que deciden cómo se ve y se comporta un escritorio Linux.
Este conjunto convierte [Hyprland](https://hypr.land) (un gestor de ventanas en mosaico) en un escritorio completo con una idea detrás:

> **Eliges un fondo de pantalla, y todo el sistema se viste a juego.**

La barra, la terminal, las notificaciones, el lanzador, la pantalla de bloqueo, la de inicio de sesión,
Discord, Firefox, Obsidian y Spotify toman sus colores de tu fondo (imágenes *y* videos), y cambian
**al momento**, sin reiniciar nada. Todo comparte el mismo estilo: marcos finos, marcas de esquina
tipo HUD y esquinas rectas.

Viene con un instalador que te pregunta las cosas en palabras normales y un menú de ajustes (`automata`),
así que **nunca tienes que tocar un archivo de configuración** a menos que quieras.

### ¿Para quién es?

- Usas **Arch** (o algo basado en Arch: EndeavourOS, CachyOS, Manjaro…) y quieres probar Hyprland
  sin pasarte un fin de semana configurándolo.
- Ya usas Hyprland y quieres la magia de los colores del fondo, o solo algunas piezas.
  Todo está separado en módulos, así que te llevas solo lo que te guste.
- Te gusta curiosear configs. Todo está comentado para eso, y agregar un módulo tuyo es crear una carpeta.

**No es para:** distros que no son Arch (puede funcionar, pero instalas los paquetes a mano), ni
Hyprland anterior a la 0.55. Esto usa la config nueva en Lua.

### Compatibilidad

| | |
|---|---|
| **Probado en** | EndeavourOS · Hyprland 0.57 · GPU AMD · escritorio, un monitor |
| **Portátiles** | La batería aparece sola en la barra; las teclas de brillo funcionan |
| **NVIDIA** | Se detecta sola y recibe las variables que recomienda la wiki de Hyprland. **Sin probar en hardware real**, los reportes se agradecen |
| **Varios monitores / HiDPI** | `automata` → Monitores (modo, escala y posición de cada uno) |
| **Shells** | bash, zsh y fish |

## Capturas

<!-- Las capturas van en assets/ y aparecen aquí -->
| Escritorio | Lanzador + selector de fondos | Bloqueo |
|:---:|:---:|:---:|
| ![](assets/desktop.png) | ![](assets/launcher.png) | ![](assets/lock.png) |
| **Discord (Vesktop)** | **Firefox** | **Spotify** |
| ![](assets/vesktop.png) | ![](assets/firefox.png) | ![](assets/spotify.png) |

## Qué trae

| Módulo | Qué obtienes |
|---|---|
| **Hyprland** | Config del gestor de ventanas: bordes en degradado, animaciones rápidas, blur, atajos, bloqueo, inactividad |
| **Waybar** | La barra: escritorios, ventana activa, reloj, música, CPU/RAM/temperatura, audio, red, menú de energía |
| **Rofi** | Lanzador de apps, selector de fondos con miniaturas, historial del portapapeles |
| **Kitty** | Terminal translúcida con los colores del fondo |
| **Dunst** | Notificaciones |
| **GTK** | Apps GTK 3/4 (Thunar, ajustes…) con la misma paleta |
| **Shell** | Un bash más cómodo: prompt, `ls` con íconos, `cd` inteligente, historial con búsqueda, fastfetch |
| **Vesktop** | Discord estilo HUD, translúcido y legible con cualquier fondo |
| **Firefox** | Interfaz HUD, tu fondo en la pestaña nueva, colores en vivo |
| **Obsidian** | Fragmento CSS para tu bóveda que se recarga solo |
| **Spotify** | Tema de Spicetify que cambia de color **en vivo**, sin `spicetify apply` cada vez |
| **SDDM** | Pantalla de inicio a juego (necesita sudo, te dice exactamente qué corre) |

## Instalar

```bash
git clone https://github.com/ianrv9/automata.lua
cd automata.lua
./install
```

Eso es todo. El instalador te lleva de la mano:

1. **Idioma**: inglés o español (todo, el escritorio también).
2. **Módulos**: eliges con las flechas. Las apps que ya tienes vienen marcadas.
3. **Ajustes**: *Rápido* (valores sensatos) o *A mi gusto* (terminal, gestor de archivos, navegador,
   teclado, carpeta de fondos, estilo de color, apariencia, posición de la barra, tiempos de bloqueo, fuentes).
4. **Tu config anterior de Hyprland** (si tienes una): sus atajos, monitores, variables y programas de inicio
   se importan a `personal.lua`, así no pierdes nada de lo que tenías. Los atajos que chocan con los del
   tema quedan comentados para que decidas.
5. **Paquetes**: te dice qué falta y te ofrece instalarlo, enseñándote antes el comando exacto.
6. **Plan**: te muestra qué archivos tuyos se van a reemplazar. Hasta aquí no se tocó nada.
7. **Instalación**: copia todo, respalda lo que reemplaza y genera tus colores.
   ¿Sin fondos todavía? Se agregan tres de ejemplo (hechos para este tema).
8. **Últimos detalles**: lo de cada app (perfil de Firefox, Spotify, pantalla de inicio). Cada cosa te pregunta antes.

> ¿Desconfiado? Igual yo. `./install --dry-run` hace el recorrido completo y te muestra lo que *haría*, sin cambiar nada.

Cada archivo que reemplaza queda respaldado en `~/.local/state/automata/backups/`, y `automata uninstall`
los devuelve todos.

## Cambiar cosas

Corre **`automata`** en una terminal y elige qué quieres cambiar:

```
 ▸ Estilo: separación, bordes, blur, animaciones
   Aplicaciones: terminal, archivos, navegador
   Distribución del teclado
   Monitores: modo, escala, posición
   Fondo y colores
   Barra
   Bloqueo y apagado de pantalla
   Fuentes
   Idioma / Language
   Agregar o quitar módulos
   Desinstalar y restaurar archivos anteriores
```

Los cambios se aplican al momento. Por debajo se guardan en `~/.config/automata/settings.conf`,
un archivo de texto que también puedes editar a mano (y luego `automata apply`):

| Ajuste | Qué hace | Por defecto |
|---|---|---|
| `LANGUAGE` | `en` o `es`, para todo el escritorio | el de tu sistema |
| `WALLPAPER_DIR` | dónde están tus fondos | `~/Pictures/Wallpapers` |
| `COLOR_SCHEME` | cómo se sacan los colores: `scheme-content`, `scheme-tonal-spot`, `scheme-vibrant`, `scheme-expressive`, `scheme-monochrome` | `scheme-content` |
| `TERMINAL` / `FILE_MANAGER` / `BROWSER` | qué abre Super+Q / E / B | kitty / thunar / firefox |
| `KB_LAYOUT` / `KB_VARIANT` | distribución del teclado | la que usas ahora |
| `GAPS_IN` / `GAPS_OUT` | separación entre ventanas / con el borde de la pantalla | 6 / 14 |
| `BORDER_SIZE` / `ROUNDING` | grosor del borde / redondeo de esquinas | 2 / 4 |
| `BLUR` | blur detrás de la barra, menús y terminal | yes |
| `ANIMATIONS` | `fast`, `relaxed` u `off` | fast |
| `INACTIVE_OPACITY` | qué tan transparentes son las ventanas sin foco | 0.94 |
| `BAR_POSITION` | `top` o `bottom` | top |
| `FONT_UI` / `FONT_MONO` | fuentes | Space Grotesk / JetBrainsMono Nerd Font |
| `LOCK_AFTER` / `SCREEN_OFF_AFTER` | minutos sin uso, `0` = nunca | 10 / 11 |
| `MONITORS` | modo, posición y escala de cada monitor (lo escribe el menú) | todo automático |
| `GPU` | `nvidia` agrega las variables de NVIDIA | detectado |

### Más allá

- **Tus cosas de Hyprland** (monitores, atajos, apps al iniciar) van en `~/.config/hypr/personal.lua`.
  Las actualizaciones no lo tocan, y se carga al final, así que manda sobre todo lo demás.
- **Tus propias plantillas de matugen**: `~/.config/automata/matugen-extra.toml`.
- **Cambiar un módulo en sí**: haz un fork, edita `modules/<nombre>/` y corre `./install`.

## Atajos

| Teclas | Hace |
|---|---|
| `Super + W` | Elegir fondo (todo se repinta) |
| `Super + Q` | Terminal |
| `Super + R` | Lanzador de apps |
| `Super + E` | Gestor de archivos |
| `Super + B` | Navegador |
| `Super + C` | Cerrar ventana |
| `Super + V` | Flotar / desflotar ventana |
| `Super + 1…0` | Ir al escritorio |
| `Super + Shift + 1…0` | Mover ventana a un escritorio |
| `Super + S` / `Super + Alt + S` | Cajón / mandar la ventana ahí |
| `Super + Shift + S` o `Impr Pant` | Captura de una zona (se edita con swappy) |
| `Super + Shift + V` | Historial del portapapeles |
| `Super + L` | Bloquear |
| `Super + Supr` | Apagar la pantalla |
| `Super + M` | Cerrar sesión (pregunta antes) |
| `Super + arrastrar` | Mover (clic izquierdo) / redimensionar (clic derecho) |

## Cómo funciona (para curiosos)

```
 fondo ──► change-wallpaper ──► matugen ──► plantillas ──► colors.css, colors.lua, …
   │                                                              │
   └──► mpvpaper (lo muestra, videos también)     cada app recarga su archivo de colores
```

- **[matugen](https://github.com/InioX/matugen)** saca una paleta Material You del fondo y rellena una
  plantilla por app. Las apps que pueden recargar en vivo (waybar, kitty, dunst, Hyprland, Obsidian,
  Vesktop) lo hacen solas. Spotify lleva un scriptcito que busca colores nuevos cada 2 segundos. Firefox lo hace a través de Pywalfox.
- **El instalador** (`bin/automata`) es bash sin más. Cada carpeta en `modules/` es un módulo:

  ```
  modules/waybar/
  ├── module.conf    nombre, descripción, paquetes, dependencias
  ├── home/          se copia a tu $HOME tal cual (con tus ajustes rellenados)
  ├── templates/     plantillas de matugen
  ├── matugen.toml   qué plantilla genera qué archivo
  └── post.sh        pasos extra (opcional)
  ```

  Los archivos pueden llevar marcadores `@@AJUSTE@@` y `@@t:texto@@`. Así un mismo archivo sirve para los dos idiomas y todos tus ajustes.
  **Agregar un módulo = agregar una carpeta.**

## Actualizar

```bash
cd automata.lua && git pull && ./install
```

Tus ajustes y tu `personal.lua` se quedan como están.

## Desinstalar

```bash
automata uninstall
```

Tus archivos de antes vuelven, y lo que agregó automata se va. Los paquetes se quedan, porque puede que los uses.

## ¿Algo falló?

Mira [docs/troubleshooting.es.md](docs/troubleshooting.es.md): crash al iniciar sesión, el monitor que se apaga,
actualizaciones de Spotify, Firefox que no cambia… Si no está ahí, abre un issue (en español, sin problema)
y pega la salida de `automata info` (las versiones de todo, es lo que hace falta para reproducirlo).

Hyprland, Discord y Firefox cambian cosas por su lado cada pocas semanas. `automata info` dice con qué
versión de Hyprland se probó por última vez, y el instalador avisa si la tuya es más nueva.

## Créditos

- [matugen](https://github.com/InioX/matugen) hace la magia de los colores.
- El tema de Vesktop está construido sobre [Midnight](https://github.com/refact0r/midnight-discord) de refact0r.
- [gum](https://github.com/charmbracelet/gum) pone bonito el instalador.
- Fuentes: [Space Grotesk](https://github.com/floriankarsten/space-grotesk), [JetBrains Mono Nerd Font](https://www.nerdfonts.com/).

MIT © Calternar. Haz lo que quieras con esto, solo deja el nombre en algún lado.
