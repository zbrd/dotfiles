#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases
[[ -f ~/.bash_prompt  ]] && . ~/.bash_prompt

exec_prog() {
    local p=${1:?program arg}
    command -v "$p" &> /dev/null && exec "$@" 1>&2 2>/dev/null
}

if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; then
    # we're in a desktop terminal emulator
    # don't do anything
    return
fi

if [ -z "$XDG_VTNR" ]; then
    # we're not in systemd
    # don't do anything
    return
fi

if [ -z "$KMS_START_SCRIPT" ]; then
    # we're in normal linux virtual console
    # try to start wayland
    exec_prog niri-session -l
fi

# start tmux for vt
# exec tmux -L vt new-session -As "vt${XDG_VTNR}"
