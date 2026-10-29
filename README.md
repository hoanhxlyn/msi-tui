# msi-tui

Keyboard-only terminal UI for the MSI GF63's `msi-ec` fan / shift / cooler boost
controls. Reads sysfs directly, writes only through the passwordless
`msi-ec-ctl` wrapper, refreshes every 2 seconds.

Renders inline (no alternate screen): it takes the rows it needs at the bottom
of the terminal and leaves your scrollback intact.

## Run

Builds need a compiler and a C toolchain (`gcc`), neither of which is on PATH by
default on this host.

```fish
# via the project dev shell (recommended)
nix develop -c cargo run --release

# or directly with nix
nix shell nixpkgs#rustc nixpkgs#cargo nixpkgs#gcc -c cargo run --release
```

The built binary is `target/release/msi-tui`.

## Keys

| Key | Action |
| --- | --- |
| `j` / `↓` | move down |
| `k` / `↑` | move up |
| `enter` | open submenu / apply selected value |
| `esc` | back to main menu |
| `q` | quit (main menu only) |

Requires a Nerd Font in the terminal for the icons
(`󰈸` fan mode, `󰓅` shift, `󱖗` boost).


## What it reads

Everything under `/sys/devices/platform/msi-ec`:

- `fan_mode`, `available_fan_modes`
- `shift_mode`, `available_shift_modes` (`unspecified` shows as `-` in the
  header and as an informational, non-applicable row in the menu)
- `cooler_boost`
- `cpu/realtime_temperature`, `cpu/realtime_fan_speed`
- `gpu/realtime_temperature`, `gpu/realtime_fan_speed`

Reads never need root, so the whole UI is safe to smoke-test:

```fish
./target/release/msi-tui   # move around, never apply anything
```

If the `msi-ec` driver or sysfs path is missing, fields render as `-`.

## Writes

Applied only via:

```sh
sudo -n /run/current-system/sw/bin/msi-ec-ctl fan-mode <value>
sudo -n /run/current-system/sw/bin/msi-ec-ctl shift-mode <value>
sudo -n /run/current-system/sw/bin/msi-ec-ctl cooler-boost <on|off>
```

One attempt per keypress, no retries. Failures show in the footer; a missing
writer (e.g. before the host rebuild that installs `msi-ec-ctl`) leaves the UI
read-only with a "writer not installed" message.

## Nix package

`flake.nix` exposes `packages.x86_64-linux.default` and a dev shell. Consuming it
from another flake:

```nix
inputs.msi-tui.url = "path:/works/msi-tui"; # or a git URL once published
# ...
environment.systemPackages = [ inputs.msi-tui.packages.${pkgs.system}.default ];
```

For writes to work from the packaged binary, the host config must also provide a
passwordless `msi-ec-ctl` wrapper at `/run/current-system/sw/bin/msi-ec-ctl`.

## Scope

Toy project: no config file, no persistence, no mouse, no write retries. Values
listed come straight from the driver's `available_*` files.
