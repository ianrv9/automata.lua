# Shell extras for fish. fish loads conf.d by itself, nothing to add anywhere.

fish_add_path -g ~/.local/bin

if type -q eza
    alias ls 'eza --icons=auto --group-directories-first'
    alias ll 'eza -l --icons=auto --git --group-directories-first --time-style=relative'
    alias la 'll -a'
    alias tree 'eza --tree --level=2 --icons=auto'
end

type -q bat; and alias cat 'bat --paging=never --style=plain'

# blue folder + magenta ❯, red ❯ when the last command failed. Same as bash and zsh
function fish_prompt
    set -l last $status
    set_color -o blue; echo -n (basename (prompt_pwd)); set_color normal
    test $last -eq 0; and set_color magenta; or set_color red
    echo -n ' ❯ '; set_color normal
end
set -g fish_greeting

type -q zoxide; and zoxide init fish --cmd cd | source
type -q fzf; and fzf --fish | source

if test "$TERM" = xterm-kitty -a "$SHLVL" -le 2; and type -q fastfetch
    fastfetch
end
