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
    local path=$1 record branch= oid= dirty= prefix= part
    # NUL-delimited porcelain v2 handles unusual filenames and includes branch
    # metadata in the same snapshot. Disable optional locks for status polling.
    while IFS= read -r -d '' record; do
        case $record in
            '# branch.head '*) branch=${record#\# branch.head } ;;
            '# branch.oid '*) oid=${record#\# branch.oid } ;;
            '1 '*|'? '*|'u '*) dirty='*' ;;
            '2 '*)
                dirty='*'
                # Renames include a separate NUL-delimited original filename.
                IFS= read -r -d '' record
                ;;
        esac
    done < <(GIT_OPTIONAL_LOCKS=0 git -C "$path" status --porcelain=v2 --branch -z 2>/dev/null)
    REPLY=
    # Missing branch metadata (including outside a repository) hides this segment.
    [[ -n $branch ]] || return 0
    if [[ $branch == '(detached)' ]]; then
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
    printf -v REPLY '‹%s%s›' "$branch" "$dirty"
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

# Allow sourcing helpers without querying tmux or rendering a status line.
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    if (( $# != 1 )); then
        printf 'Usage: status.sh PANE_ID\n' >&2
        exit 1
    fi
    # Resolve the pane's directory on every refresh so pane changes are reflected.
    current_path=$(tmux display-message -p -t "$1" '#{pane_current_path}' 2>/dev/null) || exit 0
    [[ -n $current_path ]] && render "$current_path"
fi
