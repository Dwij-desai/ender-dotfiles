# EnderOS Architecture

This document provides a repository-level architecture summary.

Detailed implementation intent is defined in [docs/AI_CONTEXT.md](docs/AI_CONTEXT.md).

## Core Modules

- Hyprland: window and workspace orchestration
- Waybar: high-signal developer instrumentation
- Walker: operating console and launcher
- SwayNC: notifications and event stream
- Hyprlock: secure access control
- Theme: shared visual tokens
- Scripts: reusable system logic

## Repository Boundaries

- [assets](assets): fonts, icons, wallpapers
- [config](config): component configuration
- [docs](docs): project and implementation documentation
- [scripts](scripts): automation and utilities
- [install](install): installer scaffolding and references
- [tests](tests): lightweight verification scripts

## Integration Principles

1. Avoid duplicate responsibilities between components.
2. Prefer shared tokens and reusable scripts.
3. Keep optional dependencies non-blocking.
4. Preserve fresh Arch Linux portability.
