#!/bin/bash

shorten_path() {
    local path=$1 parent shortened=
    if [[ $path == "$HOME" || $path == "$HOME/"* ]]; then
        path="~${path#"$HOME"}"
    fi
    # Give the usual project root a compact, recognizable name.
    case $path in
        '~/Projects'|'~/projects') path='~/P' ;;
        '~/Projects/'*) path="~/P/${path#\~/Projects/}" ;;
        '~/projects/'*) path="~/P/${path#\~/projects/}" ;;
    esac
    if (( ${#path} > 45 )); then
        # Abbreviate parent components, retaining the final directory name.
        while [[ $path == */* ]]; do
            parent=${path%%/*}
            path=${path#*/}
            shortened+="${parent:0:1}/"
        done
        path="$shortened$path"
    fi
    REPLY=$path
}

git_status() {
    local path=$1 branch= oid= prefix= part
    REPLY=
    # Read HEAD without scanning the working tree or index.
    if ! branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null); then
        # Detached HEAD shows the commit; outside a repository hides the segment.
        oid=$(git -C "$path" rev-parse --verify --short=7 HEAD 2>/dev/null) || return 0
        branch="detached:${oid:0:7}"
    else
        # Keep the final branch component intact; shorten any slash-separated prefix.
        while [[ $branch == */* ]]; do
            part=${branch%%/*}
            branch=${branch#*/}
            prefix+="${part:0:1}/"
        done
        branch="$prefix$branch"
    fi
    printf -v REPLY '‹%s›' "$branch"
}

escape() {
    # Keep Unicode glyphs while preventing control/format injection.
    local value=${1//[[:cntrl:]]/?}
    # tmux treats # as a formatting introducer; doubling it displays a literal #.
    REPLY=${value//#/##}
}

render() {
    local path=$1 git display_path
    git_status "$path"
    escape "$REPLY"
    git=$REPLY
    shorten_path "$path"
    escape "$REPLY"
    display_path=$REPLY
    # Each separator bridges the background colors of adjacent status segments.
    if [[ -n $git ]]; then
        printf '#[fg=#34394d,bg=#1a1b26]#[fg=#c0caf5,bg=#34394d] %s #[fg=#414868,bg=#34394d]' "$git"
    else
        printf '#[fg=#414868,bg=#1a1b26]'
    fi
    printf '#[fg=#c0caf5,bg=#414868] %s \n' "$display_path"
}

update() {
    local pane=$1 current_path=${2-}
    if [[ -z $current_path ]]; then
        current_path=$(tmux display-message -p -t "$pane" '#{pane_current_path}' 2>/dev/null) || return 0
    fi
    [[ -n $current_path ]] || return 0
    # tmux's #(...) status command displays the last line of standard output.
    render "$current_path"
}

# Allow sourcing helpers without querying tmux or printing the status line.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    if (( $# < 1 || $# > 2 )); then
        printf 'Usage: status.sh PANE_ID [CURRENT_PATH]\n' >&2
        exit 1
    fi
    update "$@"
fi
