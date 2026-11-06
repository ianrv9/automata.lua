// Live colors for Spotify.
// matugen writes automata-colors.json inside Spotify's xpui folder on every wallpaper change.
// It gets polled every 2 s and swap the --spice-* variables, no restart needed.
// File missing (right after a Spotify update, say)? Then color.ini's colors stay.
(function automataLiveColors() {
    const FILE = "automata-colors.json";
    let last = "";

    const hexToRgb = (hex) => {
        const h = hex.replace("#", "");
        return [0, 2, 4].map((i) => parseInt(h.substr(i, 2), 16)).join(",");
    };

    async function check() {
        try {
            const res = await fetch(FILE, { cache: "no-store" });
            if (!res.ok) return;
            const text = await res.text();
            if (text === last) return;
            last = text;
            const colors = JSON.parse(text);
            const root = document.documentElement.style;
            for (const [name, hex] of Object.entries(colors)) {
                root.setProperty(`--spice-${name}`, hex);
                root.setProperty(`--spice-rgb-${name}`, hexToRgb(hex));
            }
        } catch (e) {
            // half-written file or whatever, next round will get it
        }
    }

    check();
    setInterval(check, 2000);
})();
