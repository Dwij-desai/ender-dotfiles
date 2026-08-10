# EnderOS AI Context

> This document is the canonical implementation guide for any AI assistant contributing to EnderOS.

Before making any modification, every implementation should follow the principles defined here.

---

# Project Vision

EnderOS is a portable, engineering-first Linux workstation built on Arch Linux.

It is **not** a Linux rice.

It is **not** a macOS clone.

It is **not** a Windows clone.

It is **not** a gaming-themed desktop.

Its purpose is to create an operating environment that helps developers, engineers, researchers, and creators accomplish serious work with minimal friction.

Every design and implementation decision should prioritize functionality, clarity, portability, and maintainability.

---

# Design Philosophy

The EnderOS visual identity is inspired by:

- Industrial design
- Laboratory equipment
- Aerospace hardware
- Mission control systems
- Professional cameras
- Framework Laptop
- Nothing hardware
- Teenage Engineering
- Death Stranding's utilitarian futurism
- Japanese minimalist product design

The interface should feel engineered rather than decorated.

Core principles:

- Function creates beauty.
- Engineering before ornamentation.
- Calm rather than flashy.
- Precision rather than complexity.
- Information before decoration.
- Every component must have a purpose.

Avoid:

- RGB themes
- Cyberpunk aesthetics
- Heavy blur
- Excessive transparency
- Decorative gradients
- Oversized shadows
- Visual noise

---

# Architecture Principles

EnderOS is composed of independent modules.

Every component has a single responsibility.

Examples:

Waybar
→ developer instruments

Walker
→ operating console

SwayNC
→ event log

Hyprlock
→ secure access

Hyprland
→ window management

Theme System
→ design tokens

Scripts
→ reusable system logic

Shared assets should always be preferred over duplicated code.

---

# Dependency Rules

Portability is mandatory.

EnderOS must run on a fresh Arch Linux installation.

Core functionality must rely only on standard Arch packages whenever possible.

Preferred:

- Waybar
- Walker
- Hyprland
- SwayNC
- Hyprlock
- NetworkManager
- systemd
- Bash
- Python (when justified)

Optional enhancements are allowed.

Examples:

- Quickshell
- AGS
- Eww

These must never become required dependencies.

Graceful degradation is preferred over hard dependency failures.

---

# Instrument Philosophy

Every instrument exists to reduce a decision.

A module is successful when it eliminates routine terminal commands.

Every instrument should answer:

What is the current state?

Why should the developer care?

What action can be taken immediately?

Examples:

Network

State:
Connected

Information:
SSID
IP
Public IP
Bandwidth
Gateway

Actions:
Open nmtui
Open diagnostics

Good instruments reduce context switching.

Bad instruments merely display numbers.

---

# Coding Conventions

Prioritize:

- readability
- modularity
- maintainability
- portability

Prefer:

small reusable scripts

shared theme tokens

clear naming

consistent formatting

Avoid:

large monolithic files

duplicate logic

hardcoded values

project-specific hacks

Every new feature should integrate with the existing architecture.

---

# Directory Structure

config/

Hyprland configuration

Waybar

Walker

SwayNC

Hyprlock

Theme tokens

Shared configuration

scripts/

Reusable utilities

docs/

Project documentation

assets/

Fonts

Icons

Images

Wallpapers

Future additions should follow the existing modular layout.

---

# Repository Rules

Before implementing a feature ask:

1. Does this improve functionality?

2. Does it reduce cognitive load?

3. Does it respect portability?

4. Does it match the EnderOS design philosophy?

5. Does another component already own this responsibility?

If the answer is "no", reconsider the implementation.

Never duplicate responsibilities between components.

---

# AI Implementation Workflow

Before modifying code:

1. Read this document.

2. Read the relevant documentation.

3. Understand the existing architecture.

4. Implement only the requested change.

5. Avoid unrelated modifications.

6. Summarize:

- Files modified
- Why they changed
- New dependencies (if any)
- Portability impact

Do not rewrite existing architecture unless explicitly requested.

---

# Long-Term Goal

EnderOS should evolve into a coherent operating environment whose components work together as a unified system rather than a collection of Linux customizations.

Every contribution should move the project closer to that goal.

# Role of AI

AI assistants are implementation partners, not project designers.

Do not redesign EnderOS.

Do not introduce new visual styles.

Do not change architecture.

Do not add dependencies without justification.

When uncertain, preserve the existing design and ask for clarification rather than inventing new behavior.
