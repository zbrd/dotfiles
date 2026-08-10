alias ,='less -RF'
alias ..='cd ..'
alias cl=clear
alias clear='clear -x'
alias cp='cp -vi'
alias df.='df .'
alias df='df -h'
alias du.='du .'
alias du='du -h'
alias free='free -h'
alias la='ls -la'
alias less='less -R'
alias ll='ls -l'
alias ls='ls --color=auto'
alias mv='mv -vi'
alias pacman='pacman --color=auto'
alias psxf='ps xf'
alias rm='rm -vi'
alias tree='tree -C'
alias vi=nvim
alias vim=nvim

alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log'
alias gs='git status'

temp() {
    head -c2 /sys/class/thermal/thermal_zone12/temp
    echo
}

batt() {
    printf '%d%% %s\n' \
        "$(cat /sys/class/power_supply/BAT1/capacity)" \
        "$(cat /sys/class/power_supply/BAT1/status)"
}

pacs() {
    command pacman --color=always -Ss "$1" | command less -RF
}

man() {
    LESS='-J' MANWIDTH=$(( COLUMNS-2 )) command man --nj --nh "$@"
}

al() {
    vim ~/.bash_aliases
    . ~/.bash_aliases
}
