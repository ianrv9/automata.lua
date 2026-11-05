# Shell extras for zsh. ~/.zshrc loads this. Each block only kicks in if the tool is installed.

HISTSIZE=10000
SAVEHIST=20000
setopt hist_ignore_all_dups share_history

if command -v eza >/dev/null; then
    alias ls='eza --icons=auto --group-directories-first'
    alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
    alias la='ll -a'
    alias tree='eza --tree --level=2 --icons=auto'
fi

command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'

# blue folder + magenta ❯, red ❯ when the last command failed. Same as the bash one
setopt prompt_subst
PROMPT='%B%F{blue}%1~%f%b %(?.%F{magenta}.%F{red})❯%f '

command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"
command -v fzf >/dev/null && source <(fzf --zsh)

[[ $TERM == xterm-kitty && $SHLVL -le 2 ]] && command -v fastfetch >/dev/null && fastfetch
