# EnderOS Dotfiles

EnderOS is a portable, engineering-first Linux workstation built on Arch Linux.

This repository contains the configuration, scripts, and assets that define the EnderOS operating environment.

## Project Documents

- [AI Context](docs/AI_CONTEXT.md)
- [Architecture](ARCHITECTURE.md)
- [Components](COMPONENTS.md)
- [Roadmap](ROADMAP.md)
- [Engineering Principles](docs/ENGINEERING_PRINCIPLES.md)
- [Decisions Log](docs/DECISIONS.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## Repository Layout

```
dotfiles/
├── assets/
├── config/
├── docs/
├── install/
├── scripts/
├── tests/
├── install.sh
└── packages.txt
```

## Quick Start

1. Clone this repository.
2. Review [docs/AI_CONTEXT.md](docs/AI_CONTEXT.md).
3. Run the installer:

```bash
./install.sh
```

4. Run a health check:

```bash
./scripts/system/ender doctor
```

## Platform

- Target: Arch Linux
- Desktop stack: Hyprland + Waybar + Walker + SwayNC + Hyprlock

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
