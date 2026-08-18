alias ..='cd ..'
alias L='less -RF'
alias cl=clear
alias clear='clear -x'
alias cp='cp -vi'
alias df.='df .'
alias df='df -h'
alias du.='du .'
alias du='du -h'
alias e=nvim
alias free='free -h'
alias l=ls
alias la='ls -la'
alias less='less -R'
alias ll='ls -l'
alias ln='ln -vi'
alias ls='ls -h --color=auto --group-directories-first'
alias mkdir='mkdir -v'
alias mv='mv -vi'
alias psxf='ps xf'
alias sudo='sudo '
alias rm='rm -vi'
alias tree='tree -C'
alias vi=nvim
alias vim=nvim

# git
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log'
alias gp='git push'
alias gs='git status'

# system
alias sv='sudo sv '
alias reboot='sudo reboot '
alias poweroff='sudo poweroff '

# xbps
alias xbps-install='sudo xbps-install '
alias xbps-remove='sudo xbps-remove '
alias xbi='xbps-install '
alias xbpi='xbps-install '
alias xbq='xbps-query '
alias xbpq='xbps-query '
alias xbr='xbps-remove '
alias xbpr='xbps-remove '

# pacman
alias pacman='pacman --color=auto'

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

xbs() {
    command xbps-query -Rs "$1" | command less -RF
}

man() {
    LESS='-J' MANWIDTH=$(( COLUMNS-2 )) command man --nj --nh "$@"
}

al() {
    vim ~/.bash_aliases
    . ~/.bash_aliases
}
