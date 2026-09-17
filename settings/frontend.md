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

### Multi-value inputs

- Prefer the platform or an established headless primitive (for example,
  shadcn/Radix composition) for listbox, combobox, and popover behavior. Keep
  custom code limited to product-specific value handling and styling.
- A tag/recipient input should close its suggestions popup on blur, while
  preserving the selected values. Prevent blur races when choosing an option by
  cancelling the option's pointer-down default before committing the value.
- With an empty text input, the first Backspace selects the last chip and a
  second Backspace removes it. Do not delete a value on the first press.
- Support Ctrl/Cmd+A as a distinct bulk-selection state: show all chips as
  selected and retain one active anchor for the visible border/focus treatment.
  Typing, refocusing, adding, or removing a chip clears bulk selection.
- Give every removal control an accessible name (for example, `Remove React`),
  expose selection state with `aria-selected` where a custom composite requires
  it, and test blur, pointer selection, keyboard deletion, and bulk selection.
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

## Verification

Discover the actual package scripts and package manager. Run relevant type,
lint, formatting, and behavior checks. Verify changed UI at representative widths,
with keyboard input and supported locales. Use existing test tooling; do not
install STP's runners or formatters merely to satisfy these conventions.
