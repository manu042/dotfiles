# tmux cheat sheet

This configuration uses **Ctrl+Space** as the prefix. Press it, release it,
then press the shortcut below. `Ctrl+B` is unbound.

## Shortcuts inside tmux
https://tmuxcheatsheet.com/

| After Ctrl+Space | Action |
| --- | --- |
| `c` | New window in the active pane's working directory |
| `"` | Split into top/bottom panes in the same directory |
| `%` | Split into left/right panes in the same directory |
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

Windows are named automatically from the current directory and running app.

## Mouse and copying

- Click a pane or a window in the status bar to select it; drag a pane border
  to resize it. Scroll up to browse the pane's history (up to 20,000 lines).
- Drag to select text. Releasing the mouse copies it to the **macOS clipboard**
  through `pbcopy`, keeps the highlight, and stays in copy mode.
- A single click while in copy mode clears the selection and exits copy mode.
- Paste with the terminal's **Cmd+V**, or use **Ctrl+Space, `]`** for the latest
  tmux buffer.

Keyboard copy-mode keys need **no prefix** once copy mode is open. The config
does not force a key style: tmux defaults to Emacs, or vi when `EDITOR` or
`VISUAL` contains `vi` at server startup.

| In copy mode | Emacs keys | vi keys |
| --- | --- | --- |
| Move | Arrow keys | Arrow keys or `h`, `j`, `k`, `l` |
| Start selection | `Ctrl+Space` | `Space` |
| Copy and exit | `Alt+w` | `Enter` |
| Exit | `Escape` | `q` |

With tmux 3.7c, the keyboard copy shortcuts above also use `pbcopy` and copy to
tmux's buffer, as defined in the [upstream default bindings](https://github.com/tmux/tmux/blob/3.7c/key-bindings.c).
Check the active style with `tmux show-options -gv mode-keys`.

## Shell Commands

Run these in a terminal. Replace `work` with your
session name.

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
