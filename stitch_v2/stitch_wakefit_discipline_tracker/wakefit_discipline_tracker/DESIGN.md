---
name: WakeFit Discipline Tracker
colors:
  surface: '#051424'
  surface-dim: '#051424'
  surface-bright: '#2c3a4c'
  surface-container-lowest: '#010f1f'
  surface-container-low: '#0d1c2d'
  surface-container: '#122131'
  surface-container-high: '#1c2b3c'
  surface-container-highest: '#273647'
  on-surface: '#d4e4fa'
  on-surface-variant: '#bacac4'
  inverse-surface: '#d4e4fa'
  inverse-on-surface: '#233143'
  outline: '#84948f'
  outline-variant: '#3b4a45'
  surface-tint: '#27dfbe'
  primary: '#46f1cf'
  on-primary: '#00382e'
  primary-container: '#00d4b4'
  on-primary-container: '#005648'
  inverse-primary: '#006b5a'
  secondary: '#c3c5da'
  on-secondary: '#2d303f'
  secondary-container: '#434657'
  on-secondary-container: '#b2b4c8'
  tertiary: '#d7d7e7'
  on-tertiary: '#2e303c'
  tertiary-container: '#bbbbcb'
  on-tertiary-container: '#494b58'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#55fcda'
  primary-fixed-dim: '#27dfbe'
  on-primary-fixed: '#00201a'
  on-primary-fixed-variant: '#005143'
  secondary-fixed: '#e0e1f6'
  secondary-fixed-dim: '#c3c5da'
  on-secondary-fixed: '#181b2a'
  on-secondary-fixed-variant: '#434657'
  tertiary-fixed: '#e1e1f2'
  tertiary-fixed-dim: '#c5c5d5'
  on-tertiary-fixed: '#191b26'
  on-tertiary-fixed-variant: '#444653'
  background: '#051424'
  on-background: '#d4e4fa'
  surface-variant: '#273647'
typography:
  display-lg:
    fontFamily: metropolis
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: metropolis
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: metropolis
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
  headline-md:
    fontFamily: metropolis
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: geist
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 40px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 64px
---

## Brand & Style

The design system is built upon a philosophy of **Stoic Discipline**. It is a high-utility, high-focus environment designed to act as a strict digital coach. The aesthetic is unapologetically masculine, dark, and focused, removing all unnecessary visual noise to prioritize the user's daily objectives and streaks.

The visual style is **Modern Minimalism with a Tactical edge**. It utilizes deep, singular-tone surfaces and flat interfaces to evoke a sense of military precision. There are no decorative gradients or soft blurs; every element serves a functional purpose. The emotional response should be one of alertness, commitment, and clarity.

## Colors

The palette is rooted in a **Dark Mode First** architecture to minimize eye strain during early morning or late-night check-ins.

- **Deep Navy (#0D0F1A):** Used for the primary application background to create a sense of depth and focus.
- **Dark Surface (#1C1F2E):** Used for cards, input containers, and navigation bars.
- **Electric Teal (#00D4B4):** The primary brand accent. Reserved strictly for "Active" states, primary action buttons, and current streak indicators.
- **Semantic Palette:** Amber is used for "Warning" (missed habits), Coral Red for "Danger" (broken streaks), and Teal Green for "Success" (completed tasks).

## Typography

The typography system uses a hierarchical mix of geometric and technical fonts to reinforce the disciplined persona.

- **Headlines:** Metropolis provides a bold, architectural structure. Large displays use heavy weights and tight letter spacing to feel impactful.
- **Body:** Inter is used for its high legibility in dark environments, ensuring that instructions and logs are easily readable.
- **Labels:** Geist (Technical/Monospaced feel) is used for data points, timers, and metadata, giving the app a precise, tool-like quality.

## Layout & Spacing

This design system employs a **Fixed Grid** approach for mobile-first iOS deployment, transitioning to a structured 12-column grid for tablet/desktop views.

- **Grid:** 4 columns on mobile, 8 on tablet, 12 on desktop.
- **Rhythm:** An 8px linear scale governs all spacing.
- **Margins:** Consistent 20px side margins on mobile to ensure content doesn't feel cramped while maximizing horizontal real estate for habit tracking bars.
- **Alignment:** Strict left-alignment for all text blocks to maintain a sense of order and directness.

## Elevation & Depth

Depth in this design system is achieved through **Tonal Layering** and **Low-Contrast Outlines** rather than traditional shadows.

1.  **Level 0 (Background):** #0D0F1A.
2.  **Level 1 (Cards/Surfaces):** #1C1F2E.
3.  **Borders:** All surfaces use a subtle 1px border (#2D324A) to define edges against the deep background.
4.  **Interaction:** When an element is pressed, it does not lift (no shadow increase); instead, it gains a 1px Electric Teal border or a slight increase in surface brightness.

## Shapes

The shape language is structured and "chunky." 

- **Primary Radius:** 16px (1rem) for all main containers and cards to ensure the app feels modern and premium.
- **Small Radius:** 8px (0.5rem) for smaller interactive elements like checkboxes, input fields, and tags.
- **Interactive Elements:** Buttons are either fully rounded (pill) for secondary actions or 16px rounded for primary actions to maintain consistency with the card language.

## Components

### Buttons
- **Primary:** Solid Electric Teal background with black text (#000000). High contrast, 16px radius.
- **Secondary:** Transparent background with a 1px Teal border.
- **Ghost:** No background, #94A3B8 text for destructive or low-priority actions.

### Input Fields
- Dark surfaces (#1C1F2E) with a 1px border. Focus state changes the border to Electric Teal. Labels are always positioned above the input in `label-sm` caps.

### Cards (The "Habit" Unit)
- The primary container. Features a 16px radius. Displays the habit name in `headline-md` and the current streak in `label-md` with the Electric Teal color.

### Checkboxes & Progress
- Checkboxes are large (24x24px) with an 8px radius. When checked, they fill solid Electric Teal with a black checkmark.
- Progress bars are flat, 8px tall, with a background of #2D324A and a fill of Electric Teal.

### Tactical Elements
- **Streak Counters:** Use the `geist` font family to represent numbers, emphasizing a data-driven, technical coach feel.
- **Status Chips:** Small, rectangular tags with 4px radius, using semantic colors (Amber, Red, Green) with low-opacity backgrounds (15% opacity) and full-opacity text.