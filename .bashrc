#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_prompt  ]] && . ~/.bash_prompt

if [ "$TERM" = kmscon ]; then
    # we're in KMSCON

    if ! [ "$TMUX" ]; then
        # use a different server socket than normal tmux in wayland/x
        exec tmux -L kmscon new-session -As "TTY${XDG_VTNR}"
    fi

    # already in tmux
    # don't do anything
    return
fi

if [ -z "$WAYLAND_DISPLAY" ]; then
    # we're in a normal getty terminal
    # try to start a desktop environment

    if desktop=~/.config/desktop/"tty${XDG_VTNR}" && [ -f "$desktop" ]; then
        # helper func for desktop scripts
        # execute command only if program exists
        exec_prog() {
            local p=${1:?program arg}
            if command -v "$p" &> /dev/null; then
                exec "$@" &> /dev/null
            fi
            return 1
        }

        # run desktop environment
        . "$desktop"
    fi
fi
