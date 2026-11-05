-- Turns your old Hyprland config into a personal.lua block, so installing automata
-- doesn't eat your keybinds, monitors and autostart.
--
--   lua import-hypr.lua <old hyprland.conf|.lua> <automata's hyprland.lua>
--
-- stdout: Lua for personal.lua
-- stderr: KB_LAYOUT=… / KB_VARIANT=… / CONFLICTS=n  (the installer reads these)
--
-- Handles the common stuff. Anything it doesn't get goes in as a comment, never silently dropped.

local old_path, ours_path = arg[1], arg[2]

local function read(path)
    local f = assert(io.open(path, "r"))
    local s = f:read("a"); f:close(); return s
end

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
local function q(s) return string.format("%q", s) end

-- "SUPER + SHIFT + Q", "$mainMod SHIFT, Q", "super_shift"… all become "ALT+SHIFT+SUPER|Q"
local MOD_ALIASES = { WIN = "SUPER", LOGO = "SUPER", MOD4 = "SUPER", META = "SUPER",
                      CONTROL = "CTRL", MOD1 = "ALT" }
local function norm_mods(mods)
    local list = {}
    for m in mods:upper():gmatch("[%w]+") do
        list[#list + 1] = MOD_ALIASES[m] or m      -- (no reassigning loop vars in Lua 5.5)
    end
    table.sort(list)
    return table.concat(list, "+")
end
local function key_id(mods, key) return norm_mods(mods) .. "|" .. trim(key):upper() end
local function pretty(mods, key)
    local parts = {}
    for m in mods:upper():gmatch("[%w]+") do parts[#parts + 1] = MOD_ALIASES[m] or m end
    parts[#parts + 1] = trim(key)
    return table.concat(parts, " + ")
end

-- Keys automata already binds, read from its own hyprland.lua
local taken = {}
do
    local src = read(ours_path):gsub('mod %.%. "', '"SUPER')
    for combo in src:gmatch('hl%.bind%("([^"]+)"') do
        local mods, key = combo:match("^(.-)%s*%+%s*([^%+]+)$")
        if mods then taken[key_id(mods, key)] = combo else taken[key_id("", combo)] = combo end
    end
    for i = 0, 9 do   -- the workspace loop
        taken[key_id("SUPER", tostring(i))] = "SUPER + " .. i
        taken[key_id("SUPER SHIFT", tostring(i))] = "SUPER + SHIFT + " .. i
    end
end

-- automata already starts these, importing them would mean two of each
local ALREADY_STARTED = { waybar = true, dunst = true, mako = true, swaync = true, hypridle = true,
    hyprpaper = true, swww = true, ["swww-daemon"] = true, mpvpaper = true, ["wl-paste"] = true }

local out = { binds = {}, monitors = {}, envs = {}, autostart = {}, notes = {} }
local conflicts, kb_layout, kb_variant = 0, nil, nil

local function add_bind(mods, key, action, opts, original)
    local id = key_id(mods, key)
    local line = string.format("hl.bind(%s, %s%s)", q(pretty(mods, key)), action, opts or "")
    -- clashing close/workspace/focus binds do the same as automata's anyway, no point keeping them
    if taken[id] and not action:match("^hl%.dsp%.exec_cmd") then return end
    if taken[id] then
        conflicts = conflicts + 1
        out.binds[#out.binds + 1] = "-- same keys as automata's " .. taken[id] .. ", uncomment to override:\n-- " .. line
    else
        out.binds[#out.binds + 1] = line
    end
end

local function note(what) out.notes[#out.notes + 1] = "-- " .. what end

-- ── hyprland.conf (hyprlang) ─────────────────
local function import_conf(text)
    local vars, section = {}, {}
    local function expand(s)
        return (s:gsub("%$([%w_]+)", function(v) return vars[v] or ("$" .. v) end))
    end

    for raw in text:gmatch("[^\n]*") do
        local line = trim((raw:gsub("##", "\0"):gsub("#.*$", ""):gsub("%z", "#")))
        if line == "" then goto continue end

        if line:match("{%s*$") then
            section[#section + 1] = trim(line:gsub("{%s*$", "")); goto continue
        elseif line == "}" then
            section[#section] = nil; goto continue
        end

        local k, v = line:match("^([%w_%.%-%$:]+)%s*=%s*(.*)$")
        if not k then goto continue end
        v = expand(v)

        if k:sub(1, 1) == "$" then
            vars[k:sub(2)] = v
        elseif section[1] == "input" and (k == "kb_layout" or k == "kb_variant") then
            if k == "kb_layout" then kb_layout = v else kb_variant = v end
        elseif #section > 0 then
            -- looks/animations/etc: that's what automata replaces, skip quietly
        elseif k == "monitor" then
            local name, mode, pos, scale = v:match("^([^,]*),%s*([^,]*),?%s*([^,]*),?%s*([^,]*)")
            if mode and trim(mode) ~= "disable" then
                out.monitors[#out.monitors + 1] = string.format(
                    "hl.monitor({ output = %s, mode = %s, position = %s, scale = %s })",
                    q(trim(name)), q(trim(mode)), q(trim(pos ~= "" and pos or "auto")),
                    tonumber(scale) or q("auto"))
            else
                note("not converted: monitor = " .. v)
            end
        elseif k == "env" then
            local name, value = v:match("^([^,]+),%s*(.*)$")
            if name and not name:match("CURSOR") then
                out.envs[#out.envs + 1] = string.format("hl.env(%s, %s)", q(trim(name)), q(value))
            end
        elseif k == "exec-once" or k == "exec" then
            local prog = v:match("^%s*([^%s]+)") or ""
            prog = prog:match("([^/]+)$") or prog
            if ALREADY_STARTED[prog] then
                note("automata already starts this: " .. k .. " = " .. v)
            else
                out.autostart[#out.autostart + 1] = "    hl.exec_cmd(" .. q(v) .. ")"
            end
        elseif k:match("^bind") then
            local flags = k:sub(5)
            local mods, key, disp, args = v:match("^([^,]*),%s*([^,]+),%s*([^,]+),?%s*(.*)$")
            if not mods then note("not converted: " .. k .. " = " .. v); goto continue end
            disp, args = trim(disp), trim(args)
            local opts = {}
            if flags:find("e") then opts[#opts + 1] = "repeating = true" end
            if flags:find("l") then opts[#opts + 1] = "locked = true" end
            local o = #opts > 0 and (", { " .. table.concat(opts, ", ") .. " }") or ""
            local dirs = { l = "left", r = "right", u = "up", d = "down" }

            local action
            if flags:find("m") then action = nil   -- mouse binds: automata has drag/resize already
            elseif disp == "exec" then action = "hl.dsp.exec_cmd(" .. q(args) .. ")"
            elseif disp == "killactive" then action = "hl.dsp.window.close()"
            elseif disp == "togglefloating" then action = 'hl.dsp.window.float({ action = "toggle" })'
            elseif disp == "pseudo" then action = "hl.dsp.window.pseudo()"
            elseif disp == "workspace" and tonumber(args) then action = "hl.dsp.focus({ workspace = " .. args .. " })"
            elseif disp == "movetoworkspace" and tonumber(args) then action = "hl.dsp.window.move({ workspace = " .. args .. " })"
            elseif disp == "movefocus" and dirs[args] then action = 'hl.dsp.focus({ direction = "' .. dirs[args] .. '" })'
            end

            if action then add_bind(mods, key, action, o, v)
            elseif not flags:find("m") then note("not converted (" .. disp .. "): " .. k .. " = " .. v) end
        elseif k:match("^windowrule") or k:match("^layerrule") or k == "source" then
            note("not converted: " .. k .. " = " .. v)
        end
        ::continue::
    end
end

-- ── old hyprland.lua ─────────────────────────
-- Only one-line hl.monitor / hl.env / hl.bind calls, plus the string locals they use.
local function import_lua(text)
    local locals = {}
    for name, val in text:gmatch('\nlocal%s+([%w_]+)%s*=%s*("[^"\n]*")') do locals[name] = val end

    for line in text:gmatch("[^\n]+") do
        local l = trim(line)
        if l:match("^hl%.monitor%(.*%)$") then
            out.monitors[#out.monitors + 1] = l
        elseif l:match("^hl%.env%(.*%)$") and not l:match("CURSOR") then
            out.envs[#out.envs + 1] = l
        elseif l:match("^hl%.bind%(.*%)$") and select(2, l:gsub("%(", "")) == select(2, l:gsub("%)", "")) then
            -- resolve `mainMod .. " + Q"` into "SUPER + Q" so we can check for clashes
            local resolved = l:gsub("([%w_]+)%s*%.%.%s*\"", function(var)
                local v = locals[var]
                return v and (v:sub(1, -2)) or (var .. ' .. "')
            end)
            local combo = resolved:match('^hl%.bind%("([^"]+)"')
            local mods, key = (combo or ""):match("^(.-)%s*%+%s*([^%+]+)$")
            local id = combo and (mods and key_id(mods, key) or key_id("", combo))
            -- locals like `terminal` used inside the call get inlined too
            resolved = resolved:gsub("exec_cmd%(([%w_]+)%)", function(var)
                return "exec_cmd(" .. (locals[var] or var) .. ")"
            end)
            if id and taken[id] and not resolved:match("exec_cmd") then
                -- same idea as above: only clashing app launchers are worth keeping
            elseif id and taken[id] then
                conflicts = conflicts + 1
                out.binds[#out.binds + 1] = "-- same keys as automata's " .. taken[id] .. ", uncomment to override:\n-- " .. resolved
            else
                out.binds[#out.binds + 1] = resolved
            end
        end
    end
    note("only one-line hl.monitor/hl.env/hl.bind calls were imported; the whole old file is in automata's backups")
end

local text = read(old_path)
if old_path:match("%.lua$") then import_lua(text) else import_conf(text) end

-- ── write it out ─────────────────────────────
local function section(title, lines)
    if #lines == 0 then return end
    print("\n-- " .. title)
    for _, l in ipairs(lines) do print(l) end
end

print("-- ── imported from your old config (" .. old_path:match("[^/]+$") .. ") ──")
section("monitors", out.monitors)
section("environment", out.envs)
if #out.autostart > 0 then
    print("\n-- startup programs")
    print('hl.on("hyprland.start", function()')
    for _, l in ipairs(out.autostart) do print(l) end
    print("end)")
end
section("keybinds", out.binds)
section("left out", out.notes)
print("-- ── end of import ──")

if kb_layout then io.stderr:write("KB_LAYOUT=" .. kb_layout .. "\n") end
if kb_variant then io.stderr:write("KB_VARIANT=" .. kb_variant .. "\n") end
io.stderr:write("CONFLICTS=" .. conflicts .. "\n")
