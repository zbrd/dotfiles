# Added by zb archlinux setup script

localbin=$HOME/.local/bin

case ":$PATH:" in
    *:"$localbin":*) ;;
    *) PATH="${localbin}${PATH:+:$PATH}"
esac

unset  localbin
export EDITOR=nvim
