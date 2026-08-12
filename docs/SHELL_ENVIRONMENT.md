# EnderOS Shell Environment

## Purpose

The EnderOS shell environment provides a minimal, portable Fish and tmux foundation for workstation development. It favors command detection and standard Arch paths over machine-specific setup.

## Fish Architecture

`config/fish/config.fish` owns interactive Fish environment variables, optional integrations, aliases, history behavior, and the Yazi directory-changing wrapper. Optional commands are detected before their integration or alias is enabled.

### Tide

Tide is the active prompt. Its settings are managed by Tide and Fish, not initialized from EnderOS configuration. Do not add Starship initialization alongside Tide.

### PATH Handling

Fish adds only existing user-local paths: `$HOME/.local/bin` and `$HOME/.cargo/bin`. Do not add Homebrew, macOS, PrismLinux, Spicetify, Antigravity, or other user-product paths to the portable configuration.

### Java and Hadoop

Java is enabled only when `/usr/lib/jvm/java-21-openjdk` exists, the standard Arch location for the configured OpenJDK version. Hadoop settings are enabled only when `hadoop` and/or `/etc/hadoop` are present.

### Rust/Cargo

Cargo tools are discovered through `$HOME/.cargo/bin`. The configuration does not source a machine-generated Cargo environment file.

### Conda, fzf, zoxide, Yazi, and Kiro

- Conda initializes only when `conda` is available.
- fzf uses its Fish integration only when installed.
- zoxide uses its Fish integration only when installed; the `cd` alias is then routed to `z`.
- `y` opens Yazi and changes Fish to Yazi's final directory; it reports a clear error if Yazi is unavailable.
- Kiro integration loads only inside Kiro terminals and only when Kiro supplies a readable Fish integration script.

### CLI Utilities and Fonts

Aliases for eza, bat, ripgrep, btop, fastfetch, duf, and Neovim are enabled only when their commands exist. `fd` and git-delta require no Fish initialization. Nerd Fonts are required by eza icon aliases and the Tide configuration when icons are enabled; install a Nerd Font and select it in the terminal emulator.

Git-delta must be configured explicitly in Git configuration or through a future EnderOS Git configuration component. Fish must not mutate global Git configuration when it starts.

## tmux

`config/tmux/tmux.conf` provides the EnderOS tmux environment: `C-s` prefix, mouse support, persistent history, path-preserving splits, Vim-style pane movement and resizing, and the existing concise status bar.

TPM is optional. The configuration loads it only when `$HOME/.tmux/plugins/tpm/tpm` already exists; EnderOS does not install TPM or require tmux plugins.

## Arch Assumptions

The portable baseline expects Fish and tmux. Optional integrations use Arch packages or user-installed tools: `java-openjdk`, `hadoop`, `rust`, `conda`, `fzf`, `zoxide`, `yazi`, `eza`, `bat`, `ripgrep`, `fd`, `btop`, `fastfetch`, `duf`, `git-delta`, and a terminal Nerd Font.

## Fresh Arch Migration Rules

1. Install Fish and tmux first, then link their EnderOS configuration targets.
2. Install optional tools only when their workflow benefit justifies them; missing tools must not prevent Fish or tmux from starting.
3. Configure Tide interactively after installation and select a Nerd Font in the terminal.
4. Set Java and Hadoop versions locally if the default Arch paths do not match the required toolchain.
5. Keep secrets, Conda environments, SSH keys, Kiro installation paths, and user-specific PATH entries outside the repository.
6. Do not add `/Users/`, `/opt/homebrew`, `/usr/libexec/java_home`, or hardcoded user-home paths.
