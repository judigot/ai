# STP instruction extraction

Reviewed 2026-09-17 from `judigot/stp` checkout commit
`a34422941d8e631814c1b4424350244ef9ca3221`. This is the analyzed snapshot, not a
claim that every local source was compared with the latest remote. A remote
read of the frontend design-pattern rule also succeeded and matched the checkout.
Destination baseline: `judigot/ai` commit `9439231`.

Source root: [STP wrapper template at the analyzed commit](https://github.com/judigot/stp/tree/a34422941d8e631814c1b4424350244ef9ca3221/.wrapper-template).
All source paths below are relative to that root. The source repository is
unchanged. This is a curated extraction into the overlay, not a verbatim mirror.

## Inventory and destination

| Source | Result |
| --- | --- |
| `frontend/.cursor/rules/00-core-conventions.mdc`, `03-typescript.mdc` | Existing `settings/rules.md` already covers strict typing, narrowing, naming, and readability; project-specific imports/configuration remain conditional in [frontend conventions](../settings/frontend.md). |
| `01-react-next.mdc`, `02-styling-tailwind-clsx.mdc`, `component-structure.mdc` | Component structure, client boundaries, class composition, and layout guidance in frontend conventions. |
| `04-i18n.mdc`, `always-add-locales.mdc` | Configured-language coverage, namespaces, registration, and separation of UI labels from application data in frontend conventions. |
| `form-input-styling.mdc`, `reusable-components.mdc`, `password-validation-reuse.mdc` | Shared controls, input/error styling, accessibility, and corrected password-policy boundary in frontend conventions. |
| `design-patterns-reference.mdc` | Reference-first component/token workflow, semantic status colors, and table APIs in frontend conventions and [frontend-design](../skills/frontend-design/SKILL.md). |
| `05-testing.mdc`, `06-lint-format.mdc`, `07-scripts.mdc`, `lint-and-format.mdc` | Discover and run the consuming project's checks; existing lint/TDD skills remain authoritative. |
| `09-frontend-best-practices.mdc`, `10-external-references.mdc` | Third-party-derived generic advice not copied; existing React reference routes remain in place. |
| `backend/.cursor/frontend/rules/` | All 16 files are byte-identical to their frontend counterparts. Deduplicated. Only the frontend directory has `design-patterns-reference.mdc` (17 files total). |
| `agents/ui-to-react.md` | Adapted [ui-to-react](../agents/ui-to-react.md), with app paths discovered at runtime. |
| `agents/ui-mock-iframe.md` | Adapted [ui-mock-iframe](../agents/ui-mock-iframe.md), preserving mock-area scope and actual served-URL verification. |
| `frontend/agents/design-creation-agent.md` | Condensed [design-creation-agent](../agents/design-creation-agent.md) plus shared frontend skill/rules; added agent frontmatter. |
| `frontend/agents/remote-prompt-loader.md` | Excluded: placeholder URLs and a precedence scheme superseded by the overlay's current `AGENTS.md` and setup entrypoint. |
| `agents/agent-template.md`, `agents/README.md`, wrapper `AGENTS.md`/`CLAUDE.md` | Existing overlay agent format/loading instructions already cover these; no duplicate loader or placeholder agent added. |
| `backend/.cursor/backend/rules/00-core-conventions.mdc`, `00-core-conventions_ja.mdc`, `00-core-conventions_ext_ja.mdc` | Consolidated Java/Spring HTTP, naming, nullability, collection, and test-name guidance in [backend-java](../settings/backend-java.md). |
| `backend/.cursor/skills/junit-test-implementation/SKILL.md` and `OVERVIEW.md` | Adapted [junit-test-implementation](../skills/junit-test-implementation/SKILL.md). No frontend `SKILL.md` existed; frontend-design was synthesized from the UI rules and agents. |
| `backend/.cursor/commands/list-unimplemented-tests.md`, `generate-unit-tests-for-class.md`, `run-tests.md`, `fix-existing-tests.md`, `commit-and-push-tests.md`, `create-pr-with-test-summary.md` | Six command files folded into the JUnit skill: class/method inventory, generation, execution, repair, and authorized delivery. |
| `backend/.cursor/rules/git-no-direct-develop-main.mdc` | Existing runtime Git permissions and overlay delivery policy govern publication; no STP branch policy imposed globally. |
| `backend/.cursor/report/rules/00–07` and two report templates | Indexed by headings/descriptions: JasperReports/Excel/JRXML generation, DTOs, services, properties, tests, and issue creation. Not ported: domain-specific report automation is outside the frontend extraction. Full report bodies were not audited. |
| `.agents/`, task archives, ticket evidence | Project execution history, not reusable agent definitions; not imported. |

## Adaptation decisions

- STP mixes pnpm script instructions with Bun lint/test instructions. The overlay
  keeps Bun as its default but follows an existing app's actual package manager
  and scripts. No toolchain configuration is copied.
- Keep aliases, explicit import extensions, SCSS paths, i18n helper names,
  supported languages, and Next route groups conditional on the consuming app.
- The conversion agent and design agent disagree on page-level `PageContainer`
  ownership and list widths. Inspect the current app's layouts instead of
  imposing either document's dimensions or duplicating wrappers.
- Preserve tokens and reference components without copying fixed badge pixels,
  dynamic Tailwind class interpolation, or hardcoded brand colors.
- The source's translation examples hardcode table values. Preserve actual API
  data and localize display mappings where the product requires them.
- Do not transfer the example that compares against `currentUser.password` in
  the browser or its unsupported compliance claim. Server policy owns reuse
  checks; the UI renders localized failures.
- Do not transfer the blanket ban on imperative navigation, nested link/button
  example, assumed protected-layout inheritance of root 404 pages, or blanket
  prohibition on loading states. Follow the consuming app's route and auth model.
- The Java profile stays conditional; it does not change Hono/TypeScript defaults.
  English/Japanese rule activation flags are Cursor-specific and not exported.
- Preserve JUnit test-only scope, but do not assume production behavior is always
  correct, weaken assertions, skip all file-output tests in CI, discard conflicts
  in favor of `develop`, or require repeated user prompts to finish approved work.
- No JasperReports skill or backend-specific agent was invented from the report
  inventory. The backend's existing reusable skill was adapted directly.

## Loading and maintenance

`settings/workflow.md` routes UI work to the frontend profile/skill, HTML previews
to the iframe agent, and Java work to the backend profile/JUnit skill. Agent and
skill catalogs list the additions. Required startup files and default provider
routing are unchanged. External skill packs remain links only.
