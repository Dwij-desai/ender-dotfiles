# EnderOS Fish Environment

set -gx EDITOR nvim
set -gx VISUAL nvim

# Tide is managed by Fish and Tide itself. EnderOS does not initialize another
# prompt framework here.

# Arch Java installations expose a stable system path when java-openjdk is
# installed. Leave JAVA_HOME unset when that optional package is absent.
if test -d /usr/lib/jvm/java-21-openjdk
    set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
    fish_add_path "$JAVA_HOME/bin"
end

# Hadoop is optional and uses the standard Arch configuration location.
if type -q hadoop
    set -gx HADOOP_ROOT_LOGGER "ERROR,console"
end

if test -d /etc/hadoop
    set -gx HADOOP_CONF_DIR /etc/hadoop
end

# User-local executables and Rust tools are available when installed.
if test -d "$HOME/.local/bin"
    fish_add_path "$HOME/.local/bin"
end

if test -d "$HOME/.cargo/bin"
    fish_add_path "$HOME/.cargo/bin"
end

# Optional development tool integrations.
if type -q conda
    conda shell.fish hook | source
end

if type -q fzf
    fzf --fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if test "$TERM_PROGRAM" = kiro
    if type -q kiro
        set -l kiro_integration (kiro --locate-shell-integration-path fish)
        if test -f "$kiro_integration"
            source "$kiro_integration"
        end
    end
end

function y --description 'Launch Yazi and change to its final directory'
    if not type -q yazi
        printf '%s\n' 'Yazi is not installed.' >&2
        return 127
    end

    set -l temporary_cwd (mktemp -t 'yazi-cwd.XXXXXX')
    yazi $argv --cwd-file="$temporary_cwd"

    if test -f "$temporary_cwd"
        set -l selected_cwd (cat "$temporary_cwd")
        if test -n "$selected_cwd"; and test "$selected_cwd" != "$PWD"
            cd "$selected_cwd"
        end
    end

    rm -f "$temporary_cwd"
end

# Optional CLI utility aliases are enabled only when their backing command is
# present, so a fresh installation remains usable while tools are added.
if type -q eza
    alias ls='eza --color=always --long --git --icons=always --no-user --no-permissions --no-filesize --no-time --group-directories-first'
    alias ll='eza -lah --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias tree='eza --tree --icons --group-directories-first'
    alias treex='eza --tree --icons --group-directories-first --ignore-glob=node_modules'
end

if type -q zoxide
    alias cd='z'
end

if type -q nvim
    alias vim='nvim'
    alias vi='nvim'
end

if type -q fastfetch
    alias neofetch='fastfetch'
end

if type -q btop
    alias top='btop'
end

if type -q duf
    alias df='duf'
end

if type -q bat
    alias cat='bat'
end

if type -q rg
    alias grep='rg'
end

alias mkdir='mkdir -pv'

set -g fish_history fish
set -g fish_greeting
set -g fish_command_not_found ''
