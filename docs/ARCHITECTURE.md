# EnderOS Architecture

This document extends the root summary in [../ARCHITECTURE.md](../ARCHITECTURE.md).

## Layers

1. Base layer: Arch Linux packages and services.
2. Session layer: compositor, lock, notifications, launcher, panel.
3. Design layer: tokenized visual system.
4. Automation layer: scripts and reproducibility tooling.

## Flow

- Theme tokens are consumed by component styles.
- Scripts provide shared operations across modules.
- Installer and doctor are treated as architecture-owned interfaces.

## Constraint

Keep failures explicit and portability-first.
