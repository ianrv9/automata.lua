# Shell goodies. ~/.bashrc loads this. Every block only kicks in if the tool is installed.

HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

if command -v eza >/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
    alias la='ll -a'
    alias tree='eza --tree --level=2 --icons=auto'
fi

# plain bat adds line numbers and git markers, too much for a cat
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'

# blue folder + magenta ❯, red ❯ when the last command failed
__automata_prompt() {
    local status=$? color=35
    [ $status -ne 0 ] && color=31
    PS1="\[\e[1;34m\]\W\[\e[0m\] \[\e[${color}m\]"$'❯'"\[\e[0m\] "
}
PROMPT_COMMAND=__automata_prompt

# "cd proj" jumps to the folder you use most that matches, from anywhere
command -v zoxide >/dev/null && eval "$(zoxide init bash --cmd cd)"

# Ctrl+R searches history, Ctrl+T searches files
command -v fzf >/dev/null && eval "$(fzf --bash)"

# system summary when kitty opens (not in nested shells, that gets old fast)
[[ $TERM == xterm-kitty && $SHLVL -le 2 ]] && command -v fastfetch >/dev/null && fastfetch
