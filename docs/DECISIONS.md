# EnderOS Decisions Log

This file records major architecture and engineering decisions.

Use this format for every entry:

- Decision ID
- Date
- Title
- Decision
- Reason
- Alternatives
- Status

---

## Decision 001

Date: 2026-08-10

Title: Waybar chosen as primary status rail

Decision:

Waybar is the mandatory status interface for EnderOS Core.

Reason:

- Mature and battle-tested in Wayland environments
- Available as a standard Arch package
- Strong ecosystem of modules and patterns
- Minimal additional dependency surface

Alternatives:

- Quickshell

Rejected because:

- Additional dependency burden for core path
- Smaller ecosystem for baseline reproducibility
- Reduced portability for fresh Arch installs

Status: Accepted
