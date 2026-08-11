#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_prompt  ]] && . ~/.bash_prompt

exec_prog() {
    local p=${1:?program arg}
    if command -v "$p" &> /dev/null; then
        exec "$@" &> /dev/null
    fi
}

if [ "$TERM" = kmscon ]; then
    # we're in KMSCON

    if ! [ "$TMUX" ]; then
        # use a different server socket than normal tmux in wayland/x
        exec tmux -L kmscon new-session -As "vt${XDG_VTNR}"
    fi

    # already in tmux
    # don't do anything
    return
fi

if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    # start wayland compositor
    exec_prog niri-session -l
fi
