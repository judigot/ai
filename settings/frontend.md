# Frontend conventions

Use for React UI work. Adapted from STP; [provenance and decisions](../docs/stp-extraction.md).
Read the consuming project's configuration and reference components first. Paths,
tokens, supported languages, package managers, and helper names below describe
patterns to discover, not dependencies to install or files to create automatically.

## Components and layout

- Search the existing component gallery, style guide, and shared components before
  adding UI. Reuse their structure, tokens, and behavior.
- Keep components focused. Follow the project's folder convention; STP uses
  `src/components/Name/Name.tsx`, `INameProps`, and colocated `locales/`.
- Expose `className` when consumers need style extension. Prefer explicit props
  and composition; do not grow a configuration API for hypothetical uses.
- Parents own width and positioning; children fill the available space. Inspect
  existing route layouts before adding another page wrapper. Use section
  containers for narrower forms/cards inside wide pages.
- If width route groups exist, match each group's existing sizing token. Do not
  import STP's pixel dimensions or protected-route structure into other apps.
- Add a client boundary only where client APIs or hooks require it. Keep hook
  dependencies complete and follow the app's import/extension configuration.

## Design system and forms

- Reuse semantic color, typography, spacing, and sizing tokens. Prefer the
  project's existing Tailwind/class composition utilities (STP uses `clsx`).
- Keep class names statically discoverable by the CSS build. Use existing token
  classes or literal CSS-variable utilities instead of interpolated class names.
- Reuse the established status-to-color mapping and table header/sorting APIs.
- Reuse shared fields, buttons, password toggles, error alerts, and form styling
  helpers. Compute field error booleans once and preserve focus/error styling
  and password-toggle padding. Let buttons use the shared component's sizing.
- Where an existing `modalize` pattern is needed, the modal owns surrounding
  chrome and actions; embedded content omits duplicate titles, borders, and
  buttons. Verify both standalone and embedded modes.
- Keep password policy enforcement on the server. Localize policy failures;
  never retrieve a user's stored password or hash for a browser reuse check.

## Localization and accessibility

- For localized apps, cover labels, placeholders, actions, validation errors,
  empty states, help text, and accessible names in every configured language.
- Reuse the project's initialization and namespace registration. In STP-style
  apps, use `registerComponentLocales` and `createLocalesObject` if present;
  do not assume those utilities exist elsewhere.
- Keep locale key structures synchronized; interpolate dynamic values. Translate
  UI labels and display mappings, not raw identifiers or user-entered content.
  Format dates/numbers with the app's locale conventions. Do not hardcode API
  rows just because source examples do so.
- Prefer native links, buttons, labels, and headings. Provide accessible names,
  keyboard operation, visible focus, and appropriate live regions for errors.
- Use the router's link component for ordinary navigation, without nesting a
  button inside a link. Imperative navigation remains appropriate after actions.
- Verify dropdown dismissal does not swallow navigation or keyboard activation;
  preserve the project's event handling instead of prescribing one event globally.

## Tag input invariants

Apply this contract to every production tag or recipient input:

1. Values are trimmed, unique, controlled through one change boundary, and are
   never deleted by an accidental first Backspace.
2. Focus or typing clears chip selection. The labelled input owns combobox state
   and opens suggestions only when matching options exist.
3. Blur closes the popup and clears overlays, chip selection, and active borders.
   Pointer selection prevents pointer-down/blur races, commits once, and restores
   input focus.
4. Suggestions are a labelled listbox with stable IDs, full-width hit targets,
   active state, keyboard navigation, and above/below viewport-aware placement.
5. **Focus versus selection** — chip focus is represented by the browser's
   native focus-visible indicator, not a component-painted thick border.
   Empty-input Backspace first focuses the last chip with the selection overlay;
   the next
   Backspace removes it and moves focus to the preceding chip. Left/Right arrows
   move focus across chips, clamped at the ends. Escape closes suggestions
   without changing values.
6. Ctrl+A/Cmd+A marks every chip in the semantic bulk-selection state while the
   last chip remains natively focused. Native focus belongs to one chip; the
   other selected chips and clicked chips use the same token-colored outline
   style as duplicate pulses, but never a filled overlay. Backspace removes the entire
   bulk selection and restores focus to the text input when selection began
   there. Clicking or focusing the text input clears chip focus and
   bulk selection; typing moves focus to the input and clears the chip state.
7. Chips retain visible semantic borders in every theme; the active anchor uses a
   native focus indication. Contrast, focus indication, and forced-colors support
   must not depend on color alone.
   Password visibility controls are flush with the input edge; spacing belongs
   inside the icon button, not as an outer trailing gap.
   Its hover surface reuses the field border token so the control stays visually
   connected to the input chrome across themes.
   The icon toggle is contained inside the field, smaller than the control
   height, and centered using spacing/size tokens rather than matching the full
   input dimensions.
   The tag-input container reuses the shared focus outline through
   `:focus-within`; it must not introduce a separate blue treatment.
   Selecting a listbox option returns native focus to the text input and clears
   chip focus/selection state for predictable continued typing.
8. Clicking any chip focuses that chip and closes suggestions while clearing bulk selection; the remove
   button remains an independent action. Every remove control has an accessible name. Test focus transfer, blur,
   pointer choice, two-step deletion, bulk selection, and bulk deletion
   independently.
   Once a chip is focused, Ctrl/Cmd+A, copy, cut, and paste remain scoped to the
   tag composite and must never fall through to page-level text selection.
   Ctrl/Cmd+C copies bulk-selected values as comma-separated text. Ctrl/Cmd+X
   copies the same CSV and removes the complete selection. Pasted comma- or
   newline-delimited text is tokenized generically, trimming surrounding
   whitespace, in one atomic update (never
   one stale-state update per token); domain components should
   provide validation when a value type (for example, email) requires it.
   Paste duplicates do not mutate values; each matching existing chip receives
   the shared two-beat focus-outline pulse.

9. If a duplicate value is submitted, do not mutate the value list; pulse the
   existing chip briefly as supplemental feedback. If typing is attempted while a chip has focus, move focus to the text input
   and use a brief pulse on the previously focused chip only as supplemental
   feedback. The pulse uses the same focus outline and briefly expands its
   outline width twice in rapid succession, using animation rather than
   transitions. Respect `prefers-reduced-motion` and never use animation as the
   only focus or selection indicator.

## Verification

Discover the actual package scripts and package manager. Run relevant type,
lint, formatting, and behavior checks. Verify changed UI at representative widths,
with keyboard input and supported locales. Use existing test tooling; do not
install STP's runners or formatters merely to satisfy these conventions.
