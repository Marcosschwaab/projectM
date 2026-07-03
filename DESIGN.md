---
name: projectM
description: A modern project management tool — clean, professional, calm.
colors:
  primary: "#4f46e5"
  neutral-bg: "#f9fafb"
  neutral-surface: "#ffffff"
  neutral-text: "#111827"
  neutral-muted: "#6b7280"
  neutral-border: "#e5e7eb"
  success: "#16a34a"
  warning: "#d97706"
  error: "#dc2626"
  info: "#2563eb"
  neutral-bg-dark: "#111827"
  neutral-surface-dark: "#1f2937"
  neutral-text-dark: "#f3f4f6"
  neutral-muted-dark: "#9ca3af"
  neutral-border-dark: "#374151"
typography:
  display:
    fontFamily: "Inter, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 700
    lineHeight: 1.25
  title:
    fontFamily: "Inter, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1.125rem"
    fontWeight: 600
    lineHeight: 1.5
  body:
    fontFamily: "Inter, ui-sans-serif, system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Inter, ui-sans-serif, system-ui, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 500
    lineHeight: 1.5
rounded:
  md: "8px"
  lg: "12px"
  full: "9999px"
spacing:
  sm: "8px"
  md: "16px"
  lg: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#ffffff"
    rounded: "{rounded.md}"
    padding: "8px 16px"
    height: "36px"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.neutral-text}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
    height: "36px"
  card:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.lg}"
    padding: "24px"
  input:
    backgroundColor: "{colors.neutral-surface}"
    textColor: "{colors.neutral-text}"
    rounded: "{rounded.md}"
    height: "38px"
    padding: "8px 12px"
---

# Design System: projectM

## 1. Overview

**Creative North Star: "The Organized Desk"**

projectM is a calm, professional project management interface. Every screen is designed to disappear into the task — clean surfaces, restrained use of accent color, and consistent component vocabulary throughout. The layout prioritizes readability and hierarchy over decoration.

**Key Characteristics:**
- One type family (Inter) across the entire surface — no display/body pairing
- Indigo accent used sparingly for navigation, primary actions, and current selection — never decoration
- Cards with subtle borders and minimal shadow; surfaces feel tactile without floating
- Dark mode inverts the palette cleanly using Tailwind's `dark:` variant
- Consistent 8px spacing grid

**Explicitly rejects:** Jira/Salesforce clutter, Bootstrap admin template genericness, decorative gradient text, heavy borders, glassmorphism, hero-metric templates.

## 2. Colors

A restrained palette built around a deep indigo accent and cool gray neutrals. Light mode uses a near-white body with slate-toned surfaces. Dark mode inverts to near-black with warm-toned dark grays.

### Primary
- **Indigo** (`#4f46e5`): Primary actions, sidebar nav active state, topbar search focus ring, links. The one accent color — used on ≤10% of any given screen.

### Neutral (Light)
- **Gray-50** (`#f9fafb`): Body background.
- **White** (`#ffffff`): Card and surface backgrounds.
- **Gray-900** (`#111827`): Primary text, headings.
- **Gray-500** (`#6b7280`): Muted/secondary text, placeholders.
- **Gray-200** (`#e5e7eb`): Borders, dividers.

### Neutral (Dark)
- **Gray-900** (`#111827`): Body background.
- **Gray-800** (`#1f2937`): Card and surface backgrounds.
- **Gray-100** (`#f3f4f6`): Primary text, headings.
- **Gray-400** (`#9ca3af`): Muted/secondary text, placeholders.
- **Gray-700** (`#374151`): Borders, dividers.

### Semantic
- **Green** (`#16a34a`): Success, completion, "done" status.
- **Amber** (`#d97706`): Warnings, approval settings banner.
- **Red** (`#dc2626`): Errors, danger, sign-out, notification badge.
- **Blue** (`#2563eb`): Info, category badges.

## 3. Typography

**Display Font:** Inter (with system-ui fallback)
**Body Font:** Inter (with system-ui fallback)

One family carries the entire surface. No pairing needed. Inter's clean geometric forms keep the interface legible and neutral at every weight.

### Hierarchy
- **Display** (700, 1.5rem/24px, 1.25): Page titles (h1) — `text-2xl font-bold`
- **Title** (600, 1.125rem/18px, 1.5): Section headings (h2), card titles — `text-lg font-semibold`
- **Body** (400, 0.875rem/14px, 1.5): Most content, paragraph text — `text-sm`
- **Label** (500, 0.75rem/12px, 1.5): Form labels, stats labels, metadata — `text-xs font-medium`

Buttons and nav items use `text-sm font-medium` (0.875rem/14px, weight 500). Data/tables can run tighter at `text-xs` (0.75rem).

## 4. Elevation

Flat-by-default system. Depth is conveyed through tonal layering — cards sit on white surfaces against a gray-50 body, with a 1px border to define edges. `shadow-sm` is used sparingly on cards for subtle separation that doesn't draw attention. No floating or exaggerated shadows.

### Shadow Vocabulary
- **Card** (`box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05)`): Default card elevation — barely perceptible, just enough to separate surface from body.

## 5. Components

### Buttons
- **Shape:** 8px radius, 36px height.
- **Primary** (`bg-indigo-600 text-white`): Indigo fill, white text. Hover darkens (`hover:bg-indigo-700`). Focus ring (`focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2`).
- **Secondary** (`border border-gray-300 text-gray-700`): Ghost with border. Hover gets light bg (`hover:bg-gray-50`).
- **Danger** (`text-red-600 hover:bg-red-50`): Text-only with red tone. Used for sign-out only.

### Cards
- **Shape:** 12px radius, white background, 1px gray-200 border, subtle shadow-sm. 24px padding.
- Used for: project cards, detail panels, form sections. Not nested.

### Inputs & Form Controls
- **Shape:** 8px radius, 38px height, 1px border (gray-200), white bg. Focus replaces border with 2px indigo ring.
- Search input adds left icon padding (`pl-10`).
- Selects and textareas share the same border/radius/focus vocabulary.

### Navigation (Sidebar)
- **Width:** 256px (w-64).
- **Items:** Full-width rounded-lg buttons (8px radius), 36px tall, `text-sm font-medium`.
- **Active state:** Indigo-50 bg with indigo-700 text (dark: indigo-900/30 bg, indigo-400 text).
- **Inactive state:** Gray-600 text, hover gets gray-50 bg (dark: gray-400 text, gray-700/50 hover bg).
- Bottom section separated by border-top, contains user profile, locale switcher, theme toggle, settings, sign-out.

### Notification Badge
- 4.5px circle, red-500 fill, white 10px bold text. Positioned absolute top-right of bell icon.

### Progress Bars
- 6px height (h-1.5), full-width rounded. Fill color semantic: green (100%), blue (≥75%), amber (≥50%), red (<50%).

### Tabs / Filters
- Pill-style toggle: rounded-lg buttons, active uses indigo-100 bg, inactive uses text-gray-500.

## 6. Do's and Don'ts

- **Do** use the indigo accent sparingly — one primary action per view, active nav state, focus ring. Never decorative.
- **Don't** add side-stripe borders, gradient text, or glassmorphism — the system is flat and tonal.
- **Do** keep card padding at 24px consistently — never mix padding scales on the same surface.
- **Don't** nest cards. Use tonal layering (gray-50 bg inside a card) instead.
- **Do** use the full 4.5:1 contrast for body text — never light gray text on near-white backgrounds.
- **Don't** add display fonts or clamp-sized headings in product UI — fixed rem scale keeps the interface precise.
- **Do** keep motion under 200ms and state-driven — no page-load choreography.
- **Don't** use the hero-metric template (big number, small label, gradient accent). Present metrics as simple text in labeled cards.
