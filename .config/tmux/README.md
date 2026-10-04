# tmux cheat sheet

This configuration uses **Ctrl+Space** as the prefix. Press it, release it, then press the shortcut below. `Ctrl+B` is unbound.

More Cheat Sheets:
- https://tmux.app/cheat-sheet/
- https://tmuxcheatsheet.com/


## Shortcuts inside tmux
| After Ctrl+Space | Action |
| --- | --- |
| `c` | New window in the active pane's working directory |
| `b` | Split into left/right panes in the same directory (`split-window -h`) |
| `Shift+b` (`B`) | Split into top/bottom panes in the same directory (`split-window -v`) |
| Arrow keys | Move to the pane in that direction |
| `o` / `;` | Next pane / previously active pane |
| `z` | Zoom the active pane; press again to restore the layout |
| `q` | Show pane numbers; press a displayed number to select it |
| `n` / `p` | Next / previous window |
| `0`–`9` | Select a window by number |
| `l` | Previously selected window |
| `w` | Choose a window from the session/window tree |
| `s` | Choose a session |
| `,` / `$` | Rename the current window / session |
| `d` | Detach; the session and its programs keep running |
| `[` / `]` | Enter scrollback/copy mode / paste the latest tmux buffer |
| `x` / `&` | Close the active pane / window, after confirmation |
| `:` | Open the tmux command prompt |
| `?` | Show all key bindings |
| `Ctrl+Space` | Send a literal Ctrl+Space to the application |

The default `"` and `%` split shortcuts are unbound.

Windows and panes are numbered from **1**. Windows are renumbered automatically when one is closed.

Windows are named automatically: the directory name at a shell, or `directory/app` while an app is running. The home directory appears as `~`(or `~/app` while an app is running).
Names are capped at 20 characters, abbreviating the directory first; very long app names are capped at 17.


## Status bar
The bar sits below the panes and is configured to refresh every five seconds, including while the terminal is idle.

The path uses `~` for home and `~/P` for `~/Projects` or `~/projects`.
Paths longer than 45 characters abbreviate parent directories, keeping the final directory intact. These Git and path segments come from [status.sh](status.sh), which must be available at `~/.config/tmux/status.sh`.
The script reads only the current branch, without scanning the working tree for changes or adding a `*` dirty indicator. 
Slash-separated branch prefixes are abbreviated to their initials; the final component stays intact.
With a detached HEAD, it shows `detached:` followed by the short commit ID.

`tmux.conf` invokes `status.sh` through `#(...)`, which displays the rendered Git/path segment from the script's standard output.

Window labels use tmux's automatic renaming and show the current directory/app.


## Mouse and copying
- Click a pane or a window in the status bar to select it; drag a pane border to resize it. Scroll up to browse the pane's history.
- Drag to select text. Releasing the mouse copies it to the **clipboard** through `pbcopy`, keeps the highlight, and stays in copy mode.
- The top-right indicator shows the scroll position and history size.
- A single click while in copy mode clears the selection and keeps copy mode open.
- Press `q` without the prefix to exit copy mode.
- Paste with the terminal's **Cmd+V**, or use **Ctrl+Space, `]`** for the latest tmux buffer.

Keyboard copy-mode keys need **no prefix** once copy mode is open. The config uses vi keys.

| In copy mode | Emacs keys | vi keys |
| --- | --- | --- |
| Move | Arrow keys | Arrow keys or `h`, `j`, `k`, `l` |
| Start selection | `Ctrl+Space` | `Space` |
| Copy and exit | `Alt+w` | `Enter` |
| Exit | `q` or `Escape` | `q` |

With tmux 3.7c, the keyboard copy shortcuts above also use `pbcopy` and copy to tmux's buffer, as defined in the [upstream default bindings](https://github.com/tmux/tmux/blob/3.7c/key-bindings.c).
Check the active window's style with `tmux show-options -w -v mode-keys`.

For Linux, replace `pbcopy` in `tmux.conf` with one of the commented alternatives:
- `wl-copy` for Wayland (requires `wl-clipboard`)
- `xclip -selection clipboard` for X11 (requires `xclip`).
Terminal clipboard escapes are disabled with `set-clipboard off`.


## Shell Commands
Run these in a terminal. Replace `work` with your session name.

```sh
tmux ls                          # List sessions
tmux attach                      # Attach to the most recently used session

tmux new-session -s work         # Create and attach to a named session
tmux new-session -A -s work      # Attach if it exists; otherwise create it

tmux attach -t work              # Attach to the named session work
tmux attach-session -t work      # Reattach to a session
tmux switch-client -t work       # Switch sessions when already inside tmux

tmux list-keys -T prefix         # Inspect prefix shortcuts
tmux clear-history               # Clear scrollback history for the current pane
```


## tmux commands
Press **Ctrl+Space**, then **`:`**, type a command, and press **Enter**.

| Command | Action |
| --- | --- |
| `clear-history` | Clear the current pane's scrollback |
| `source-file ~/.config/tmux/tmux.conf` | Reload your config |
| `show-options -g` | Inspect global settings |
| `select-layout tiled` | Arrange panes in a grid |
| `break-pane` | Move the current pane into its own window |
| `join-pane -s work:1` | Move a pane from window 1 of session `work` into this window |
| `capture-pane -S -` | Copy the pane's contents and scrollback into a tmux buffer |
| `save-buffer ~/tmux-history.txt` | Save the buffer to a file |
