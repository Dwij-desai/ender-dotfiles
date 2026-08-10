# EnderOS Design System

## Purpose

The EnderOS Design System defines the visual language shared across every user interface component.

Every application, widget, and configuration should follow these principles.

---

# Philosophy

The desktop should feel engineered rather than decorated.

Beauty comes from precision, consistency, and functionality.

---

# Design Principles

- Function creates beauty.
- High information density.
- Minimal visual noise.
- Engineering before decoration.
- Color communicates state.
- Typography communicates structure.

---

# Color Rules

Primary interface colors are monochrome.

Accent colors are used only to communicate state.

Never use decorative colors.

---

# Motion

Animations should feel mechanical.

No playful transitions.

No unnecessary effects.

---

# Typography

Use technical, monospaced fonts.

Consistency is preferred over expression.

---

# Component Rules

Every component should answer:

1. Does it improve functionality?
2. Does it reduce cognitive load?
3. Does it reinforce the engineering aesthetic?
4. Would it look natural on laboratory equipment?

If not, it should not exist.

---

# Instrument Philosophy

EnderOS instruments are operational tools, not decorative widgets.

Each instrument must answer a single actionable question that reduces a decision during software development, system administration, or creative work.

The purpose of an instrument is not to expose telemetry.

The purpose of an instrument is to eliminate routine terminal queries.

Before adding information to an instrument, ask:

- What decision does this information enable?
- What command does this save the user from typing?
- What action should the user take if this value changes?

If no action follows from the information, it does not belong in the instrument.

Every instrument should follow the same hierarchy:

1. Readiness
2. Supporting information
3. Available actions

The user should be able to determine whether work can continue within one or two seconds of opening the panel.
