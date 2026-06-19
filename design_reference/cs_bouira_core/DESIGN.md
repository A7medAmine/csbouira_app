---
name: CS Bouira Core
colors:
  surface: '#111221'
  surface-dim: '#111221'
  surface-bright: '#373849'
  surface-container-lowest: '#0c0d1c'
  surface-container-low: '#191a2a'
  surface-container: '#1d1e2e'
  surface-container-high: '#282939'
  surface-container-highest: '#323344'
  on-surface: '#e1e0f6'
  on-surface-variant: '#c2c6d8'
  inverse-surface: '#e1e0f6'
  inverse-on-surface: '#2e2f3f'
  outline: '#8c90a1'
  outline-variant: '#424655'
  surface-tint: '#b2c5ff'
  primary: '#b2c5ff'
  on-primary: '#002c72'
  primary-container: '#5a8cff'
  on-primary-container: '#002564'
  inverse-primary: '#0056d1'
  secondary: '#c7c5d3'
  on-secondary: '#302f3a'
  secondary-container: '#494854'
  on-secondary-container: '#b9b7c5'
  tertiary: '#c7c5d5'
  on-tertiary: '#2f2f3c'
  tertiary-container: '#918f9f'
  on-tertiary-container: '#292935'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#dae2ff'
  primary-fixed-dim: '#b2c5ff'
  on-primary-fixed: '#001847'
  on-primary-fixed-variant: '#0040a0'
  secondary-fixed: '#e4e1ef'
  secondary-fixed-dim: '#c7c5d3'
  on-secondary-fixed: '#1b1b25'
  on-secondary-fixed-variant: '#464651'
  tertiary-fixed: '#e3e0f2'
  tertiary-fixed-dim: '#c7c5d5'
  on-tertiary-fixed: '#1a1a26'
  on-tertiary-fixed-variant: '#464553'
  background: '#111221'
  on-background: '#e1e0f6'
  surface-variant: '#323344'
typography:
  display-lg:
    fontFamily: Manrope
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Manrope
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  code-sm:
    fontFamily: jetbrainsMono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1280px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 32px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is built on a **Modern Fintech** aesthetic, characterized by precision, high-density information architecture, and a "dark-first" philosophy. The target audience—Computer Science students—requires an environment that balances academic rigor with the sleek, high-performance feel of a developer tool.

The visual style utilizes **Minimalism** with **Glassmorphism** accents. It prioritizes clarity through generous negative space and a structured hierarchy. The interface should feel technical and innovative (the "CS" aspect) while remaining approachable and organized (the "Resource Hub" aspect). Emotional responses should range from focus and productivity to a sense of digital-native fluency.

## Colors

The palette is anchored by "Electric Blue," a high-vibrancy accent that drives action and signals interactivity. 

**Dark Mode (Default):** Use `#0D0D14` for the base canvas. Surface layers (`#15151F`) should be used for cards and navigation elements to create subtle depth. Primary text remains pure white for maximum legibility against deep backgrounds.

**Light Mode:** The background shifts to a cool-grey `#F7F8FA`. Surfaces transition to pure white with soft, low-opacity borders rather than heavy shadows to maintain the fintech cleanliness.

**Functional Colors:**
- **Success:** Emerald green for completed modules or submitted assignments.
- **Error:** High-chroma red for validation states, paired with the standard accent border logic.
- **Glows:** Use 15-20% opacity of the Primary Accent for background blurs behind featured content or active CTAs.

## Typography

This design system uses a dual-type approach. **Manrope** is used for headlines to provide a modern, geometric, and slightly more "designed" feel that resonates with the fintech aesthetic. **Inter** is utilized for body copy and UI labels due to its exceptional legibility at small sizes and its systematic, neutral character.

For academic content, a monospaced font (JetBrains Mono) is introduced for code snippets and technical metadata. Ensure a clear typographic scale where headers are significantly weighted to help students scan through dense documentation quickly.

## Layout & Spacing

The design system employs a **Fluid Grid** with fixed maximum constraints. 
- **Desktop:** 12-column grid, 24px gutters, 32px side margins.
- **Tablet:** 8-column grid, 16px gutters, 24px side margins.
- **Mobile:** 4-column grid, 16px gutters, 16px side margins.

Spacing follows a strict 4px base unit. Component internal padding should favor the "stack" variables to ensure consistent vertical rhythm. Use "Safe Areas" for mobile navigation bars, ensuring bottom-tab navigation is easily reachable.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** and **Soft Ambient Shadows**. 

1.  **Level 0 (Base):** Background color (`#0D0D14`).
2.  **Level 1 (Surface):** Cards and main navigation bars (`#15151F`). No shadows, or a 1px border of `#1A1A26`.
3.  **Level 2 (Raised):** Modals, dropdowns, and floating elements. These use a diffused shadow: `0 8px 32px rgba(0, 0, 0, 0.4)` and a subtle top-light border to simulate a physical edge.

For primary CTAs, apply a **Soft Blue Glow**: an outer shadow using the primary accent color at 15% opacity with a large blur radius (20px+) to create a "pulsing" digital effect.

## Shapes

The shape language is sophisticated and modern. 
- **Large Containers/Cards:** Use a generous 20px radius (`rounded-xl`) to soften the technical aesthetic.
- **Standard Components:** Buttons and input fields use a 12px radius, providing a sturdy, clickable feel.
- **Utility Elements:** Chips, tags, and Floating Action Buttons (FABs) use a full **Pill** (999px) radius to differentiate them from structural content.

All icons must use **Rounded Caps and Joins** to align with the soft-radius geometry of the containers.

## Components

### Buttons
- **Primary:** Solid Electric Blue background, white text. On press, scale to 0.98x.
- **Secondary:** Outlined with a 1.5px border of the primary color.
- **Ghost:** No background, primary color text; used for secondary actions like "Cancel."

### Input Fields
- **Default State:** Surface color background, 1.5px border of `#1A1A26`.
- **Focus State:** Border transitions to Electric Blue with a 2px outer glow of the same color at 10% opacity.
- **Error State:** Border transitions to Red, with helper text appearing below in the same color.

### Cards
- **Resource Cards:** Include a top-aligned category chip (Pill), a Manrope Headline-md, and a brief Inter Body-md description.
- **Interactive State:** On hover, the border color should shift from the surface tone to a subtle blue tint.

### Navigation
- **Breadcrumbs:** Use Inter Label-md. Separators should be subtle forward slashes or chevrons in the secondary text color.
- **Skeleton Loaders:** Use a linear gradient shimmer moving from `#15151F` to `#1A1A26` and back, with an ease-in-out duration of 1.5s.

### Chips & Tags
- **Academic Tags:** Small pill-shaped containers with 10% primary color fill and 100% primary color text.