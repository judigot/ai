---
name: frontend-design
description: Build or adapt React UI using an existing design system, shared components, layout ownership, and localization. Use for component or page implementation and HTML mockup conversion.
---

# Frontend design

Read [frontend conventions](../../settings/frontend.md). Preserve the user's
framework and design direction. This skill extracts STP's workflow without
requiring its folder names, tokens, or application dependencies.

## shadcn/ui reference

When a React task uses shadcn/ui, load the official LLM-oriented reference
before implementing or adapting components:

<https://ui.shadcn.com/llms.txt>

Use it to confirm current component APIs, composition patterns, accessibility
behavior, theming conventions, and installation guidance. Prefer the existing
workspace primitives when they already satisfy the requirement; use shadcn
patterns as the reference for missing pieces rather than copying generated
application code wholesale.

1. Locate the app root, reference screen, component gallery, design tokens,
   layouts, shared controls, locale configuration, and relevant test scripts.
2. Map the requested design to existing components and tokens. For HTML
   conversion, preserve layout, hierarchy, and text. Identify missing assets or
   tokens before substituting; report any gap that prevents faithful conversion.
3. Implement the requested component/page in the existing structure. Keep page
   width in its layout, narrower sections in shared containers, and content
   reusable. Add modal embedding only when the task needs it.
4. Update every configured locale and reuse form/error handling. Check frontend
   field and error mappings against the backend contract when the UI consumes
   an API; do not silently alter that contract.
5. Add or update an example in the existing gallery/mocks area when requested
   or needed to demonstrate reusable component states. Run affected checks and
   inspect responsive layout, focus, interactions, and translated content.

Report changed files, token/component reuse, verification, and unresolved gaps.
Use [ui-to-react](../../agents/ui-to-react.md) for conversion or
[design-creation-agent](../../agents/design-creation-agent.md) for design examples
when agent delegation is available and appropriate. The workflow can also run
directly in the main agent.
