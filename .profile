# shell-agnostic

addpath () {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) [ -d "$1" ] && PATH="$1${PATH:+:$PATH}"
    esac
}

addpath "$HOME/.local/bin"

unset -f addpath
