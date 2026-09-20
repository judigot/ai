# PR shell contract

A PR shell is a draft pull request created before implementation. It is the
durable contract between planning/orchestration and an implementation worker.
It may contain a small planning-only file when GitHub needs a branch difference
to create the PR, but it must not contain production implementation merely to
make the PR creatable.

Use a PR shell when work should be specified now and implemented later, when an
unattended worker will execute it, or when multiple PRs need dependency-aware
parallel/sequential scheduling. Ordinary completed PRs continue to use
`settings/pr-body.md`.

## Invariants

- PR shells are draft PRs until the ready-state rules pass.
- The PR description is the implementation contract.
- Git is the source of truth for branch, commits, worktree state, and PR state.
- `depends_on` is the canonical dependency direction. Derive reverse
  dependencies instead of maintaining a second list.
- Two active workers must not have overlapping writable ownership.
- Repository-native PR metadata must agree with this shell's dependency and ownership contract; see `settings/repository-pr-contracts.md`.
- Acceptance criteria describe observable behavior, not source-code similarity.
- Workers may not weaken acceptance criteria to fit an implementation.
- CI is the final success signal when CI applies.
- The orchestrator, not the implementation worker, decides when a shell becomes
  ready for review.

## Repository PR adapter

Before opening or updating a shell, apply `settings/repository-pr-contracts.md`. If the target repository requires machine-readable dependency, stacking, or ownership metadata, derive it from this shell instead of inventing a second plan. For `judigot/scaffolder`, keep `depends_on`, `stacked_on`, and `touch_set` synchronized with the shell and treat `PR CI / PR Gate` as the stable PR readiness signal.

## Title

Use Conventional Commit style:

```text
<type>: <concise implementation goal>
```

Examples:

```text
test: establish Hono-Nest migration parity
feat: add production auth parity
fix: normalize postgres default expressions
```

Describe the deliverable, not implementation trivia.

## Required description structure

Every PR shell must contain these sections in this order:

```markdown
## PR shell

## Goal

## Why

## Dependency metadata

## Scope

## Ownership boundaries

## Interfaces and contracts

## Acceptance criteria

## Required tests

## How to verify (manual)

## Required checks

## Out of scope

## Escalation rules

## Ready-state rules

## Worker completion report
```

Required sections may be extended, but not removed.

## PR shell metadata

Start the body with this exact field set:

```yaml
version: 1
state: planned
execution: independent
base: main
depends_on: []
worker: implementation
preferred_model: gpt-5.6-luna
reasoning_effort: low
```

### `version`

Contract version. For this contract:

```yaml
version: 1
```

### `state`

Allowed values:

- `planned` — shell exists; implementation has not started.
- `implementing` — a worker owns the PR and implementation is in progress.
- `blocked` — safe autonomous progress cannot continue.
- `verification` — implementation is complete enough for full checks/review.
- `ready` — every ready-state requirement has passed.

Workers may advance state through `verification`. Only the orchestrator may set
`state: ready`.

### `execution`

Allowed values:

- `independent` — may execute concurrently with unrelated shells.
- `sequential` — wait until dependencies reach the required parent state.
- `stacked` — may build on a completed/pushed parent branch before the parent
  reaches `main`.
- `foundation` — complete this shared base before dependent work fans out.

### `base`

The expected Git base branch or ref.

```yaml
base: main
```

For a stacked shell:

```yaml
base: feat/parent-contract
```

### `depends_on`

PR numbers that provide required behavior or code.

```yaml
depends_on: []
```

or:

```yaml
depends_on:
  - 78
  - 81
```

Do not maintain a `dependents` field. The orchestrator derives the reverse
edges from all shells.

### `worker`

Default:

```yaml
worker: implementation
```

Future values may include `research`, `migration`, or `documentation`.
Worker routing still follows `settings/agent-orchestration.md`.

### `preferred_model` and `reasoning_effort`

These are routing hints, not authorization to bypass canonical orchestration
policy.

```yaml
preferred_model: gpt-5.6-luna
reasoning_effort: low
```

## Goal

One paragraph maximum. State the observable end condition.

Good:

```markdown
## Goal

Generate Hono and NestJS backends from the same schemaInfo and prove that their
migrations converge to the same normalized PostgreSQL schema.
```

Do not turn this section into an implementation checklist.

## Why

Maximum three sentences:

1. the problem;
2. why it matters;
3. optionally what future work it enables.

Keep this understandable without reading repository code.

## Dependency metadata

Repeat the machine-readable dependency in plain language and declare the parent
gate.

Template:

```markdown
## Dependency metadata

- Depends on: none
- Execution: independent
- Provides foundation for: #79
- Required parent state: none
```

Dependent example:

```markdown
## Dependency metadata

- Depends on: #78
- Execution: stacked
- Provides foundation for: #80
- Required parent state: implementation complete, pushed, and focused checks green
```

Execution rules:

- Independent shells may run together only when writable ownership does not
  overlap.
- Sequential shells do not start implementation until dependencies satisfy the
  declared parent gate.
- Stacked shells may start from the dependency branch once the parent is pushed,
  passes its focused checks, and the orchestrator considers it stable enough.
- Foundation shells complete before dependent work fans out.

## Scope

Use checkboxes for concrete deliverables:

```markdown
## Scope

- [ ] Generate Hono and NestJS from one shared schema fixture.
- [ ] Apply both migration sets to isolated PostgreSQL databases.
- [ ] Introspect and normalize both resulting schemas.
- [ ] Report useful semantic mismatch diagnostics.
```

Every item must contribute directly to the Goal. Do not add adjacent
nice-to-have work.

## Ownership boundaries

Use all three subsections:

```markdown
## Ownership boundaries

### Owned

- `tests/parity/**`
- existing PostgreSQL normalization helpers required by this PR

### Read-only / reference

- `apps/web/**`
- existing OpenAPI implementation

### Do not touch

- authentication
- Spring generator
- Laravel generator
```

### Owned

List paths or semantic areas the worker may modify. Prefer concrete paths once
known.

For the hardened one-shot executor, writable ownership must also be
machine-checkable. Use repository-specific `touch_set` metadata when required.
Otherwise, every Owned item used for parallel execution must be an explicit
repository path wrapped in backticks. Semantic phrases alone do not satisfy
one-shot overlap/scope enforcement.

### Read-only / reference

List useful context that must not be modified by this worker.

### Do not touch

List explicit scope boundaries, especially nearby work owned by later PRs.

### Ownership expansion

If an unlisted file must change, the worker reports it and the orchestrator
checks concurrent ownership before expanding the worker's scope.

During an unattended run, a worker may expand ownership without interaction only
when all are true:

- the file is necessary for an existing acceptance criterion;
- no concurrent worker owns it;
- the change does not broaden product scope;
- the expansion is recorded in the completion report.

Shared architectural files should normally remain orchestrator-owned.

## Interfaces and contracts

Lock the smallest shared contracts needed to let independent implementation
tasks proceed without improvising incompatible behavior.

Include applicable API shapes, types, events, error behavior, loading/empty
states, persistence shapes, or other cross-task interfaces.

Example:

````markdown
## Interfaces and contracts

### Product search

`GET /api/products?q=<query>`

```ts
interface ISearchResponse {
  products: Array<{
    id: string;
    name: string;
    price: number;
  }>;
}
```

- Empty query: return the repository-standard validation response.
- Empty result: `products: []`.
- UI loading and error behavior follow the existing product-list conventions.
````

Do not invent interface detail merely to fill this section. If no cross-task
interface is needed, write `None`.

During parallel implementation, workers consume the locked contract. A worker
that discovers a necessary contract change reports it to the PR parent
immediately and does not independently redefine the interface. The parent owns
contract changes and propagates the updated interface before dependent work
continues.

## Acceptance criteria

Give every criterion a stable ID:

```markdown
## Acceptance criteria

- [ ] AC-01: One schemaInfo fixture generates both Hono and NestJS.
- [ ] AC-02: Resulting tables and columns are semantically equivalent.
- [ ] AC-03: Primary keys are semantically equivalent.
- [ ] AC-04: Foreign keys are semantically equivalent.
- [ ] AC-05: Unique constraints are semantically equivalent.
- [ ] AC-06: Indexes are semantically equivalent.
- [ ] AC-07: A deliberate mismatch identifies the semantic difference.
```

Criteria must be independently verifiable. Avoid vague words such as "robust",
"clean", "proper", or "enterprise-grade" unless measurable behavior follows.

Workers may not remove, weaken, or reinterpret a criterion to fit their code.
Contradictory/impossible criteria are escalation conditions.

## Required tests

Map acceptance IDs to behavior:

```markdown
## Required tests

| Acceptance | Required behavior/test |
| --- | --- |
| AC-01 | `generates_hono_and_nest_from_same_schema_info` |
| AC-02 | migration schema parity |
| AC-03 | primary-key parity |
| AC-04 | foreign-key parity |
| AC-05 | unique-constraint parity |
| AC-06 | index parity |
| AC-07 | semantic mismatch diagnostics |
```

Exact test names may follow repository conventions, but required behavior may
not disappear because a name changes.

For implementation shells, apply TDD when the criterion can be tested first:

```text
acceptance criterion
        ↓
failing test
        ↓
implementation
        ↓
green test
```

## How to verify (manual)

Keep compatibility with `settings/pr-body.md`. Give a non-technical person the
simplest meaningful verification flow.

Example:

```markdown
## How to verify (manual)

- [ ] Open the PR's Checks tab.
- [ ] Confirm the migration-parity job is green.
- [ ] A failure should identify the specific schema difference.
```

For backend/infrastructure-only work, a checks-based flow is acceptable. Do not
invent a fake UI flow.

## Required checks

List verification categories, not stale command guesses:

```markdown
## Required checks

- [ ] Focused acceptance tests
- [ ] Affected regression tests
- [ ] Typecheck
- [ ] Formatter/linter checks configured by the repository
- [ ] `git diff --check`
- [ ] Required CI checks are green
```

Workers discover current commands from the repository/workflows. CI remains the
final success signal when it applies.

## Out of scope

Name adjacent work that must not be absorbed:

```markdown
## Out of scope

- OpenAPI parity
- runtime CRUD parity
- authentication and authorization
- Spring Boot
- Laravel
```

If an out-of-scope capability appears necessary, first seek an in-scope
solution. Otherwise escalate instead of silently implementing future work.

## Escalation rules

Default:

```markdown
## Escalation rules

Resolve autonomously:
- syntax/type errors
- lint/format failures
- ordinary failing tests
- implementation choices covered by existing patterns
- framework/API documentation lookup
- mechanical refactors required by acceptance criteria

Escalate when:
- acceptance criteria contradict each other
- required behavior changes shared architecture
- writable ownership overlaps another active worker
- satisfying this PR changes a dependency's contract
- multiple valid choices materially affect future PRs
- a required test cannot be meaningful without changing the specification
```

Model routing follows the canonical orchestration policy. Ordinary
implementation failures should not escalate to the most expensive model.

## Ready-state rules

Implementation completion is not PR readiness. For hardened one-shot execution,
the implementation runner releases its model slot after verified push and a
separate readiness monitor waits for the exact required check/status contexts on
that exact pushed SHA. Missing required contexts remain not-ready; a required
skipped context is not success.

A shell may leave draft state only when all applicable conditions are true:

```markdown
## Ready-state rules

- [ ] Every acceptance criterion is satisfied.
- [ ] Every required acceptance test passes.
- [ ] Affected regression tests pass.
- [ ] Required lint/type/static checks pass.
- [ ] Required runtime/integration checks pass.
- [ ] Required CI checks are green.
- [ ] No known in-scope blocker remains.
- [ ] No acceptance test was weakened to accommodate the implementation.
- [ ] The final diff stays inside this PR's scope.
- [ ] Worker completion report is present.
- [ ] Self-audit is complete.
```

For stacked shells, implementation may complete while the parent remains open.
The shell may be considered ready only when its diff relative to the declared
parent is correct, the parent commit it relies on is pushed, and its own checks
pass against that parent. The orchestrator may keep it draft for review order.

Never mark ready while any required check is red/missing unexpectedly, an
in-scope TODO remains, implementation is uncommitted, ownership conflicts are
unresolved, a criterion was intentionally skipped, or the worker changed the
contract instead of satisfying it.

## Worker completion report

Workers keep this concise so a higher-tier model does not need their full
transcript. For one-shot execution, record which executor actually completed
the task so retries and parent fallbacks remain observable without preserving a
model conversation:

```markdown
## Worker completion report

### Execution

- Parent route: Luna low
- Completed by: parent | worker shard(s) | parent fallback | other
- Parallel task shards: [task → owner → editable paths]
- Replacements/fallbacks: none

### Implementation

- [concise change]

### Files changed

- `path/to/file`

### Acceptance criteria

- AC-01: pass
- AC-02: pass

### Verification

- `<command/check>` → pass

### Ownership expansions

- None

### Intentional differences

- None

### Remaining failures

- None

### Deferred work

- [out-of-scope follow-up only]
```

Do not include chain-of-thought, terminal transcripts, or verbose narration.

## Orchestrator interpretation

When discovering multiple shells, the orchestrator must:

1. parse all `depends_on` relationships;
2. reject dependency cycles;
3. build a dependency DAG;
4. classify currently executable nodes;
5. check writable ownership overlap;
6. choose independent, sequential, stacked, or foundation execution;
7. allocate an isolated runner/process and checkout or worktree per concurrent
   PR implementation;
8. route bounded implementation using `settings/agent-orchestration.md`;
9. advance shell state as work progresses;
10. mark shells ready only after their ready-state rules pass.

Execution waves follow the DAG, not PR-number ordering.

Example:

```text
#101 ──→ #104 ──→ #107
  │
  └────→ #105

#102 ──→ #106

#103
```

Possible waves, assuming ownership does not overlap:

```text
Wave 1: #101, #102, #103
Wave 2: #104, #105, #106
Wave 3: #107
```

## Completeness gate

A PR shell is implementation-ready only when a worker can answer all of these
without inventing product decisions:

- What must become true?
- Why are we doing it?
- What may I change?
- What must I not change?
- What work must already exist?
- Which shared interfaces/data shapes are locked?
- Can I run in parallel?
- What tests prove completion?
- What checks must pass?
- When am I allowed to stop?
- When must I escalate?

If any answer is missing, the shell is not implementation-ready.


## Copyable template

Use this template when creating a new PR shell:

````markdown
## PR shell

```yaml
version: 1
state: planned
execution: independent
base: main
depends_on: []
worker: implementation
preferred_model: gpt-5.6-luna
reasoning_effort: low
```

## Goal

[One paragraph maximum: the observable end condition.]

## Why

[Problem, why it matters, and optionally what future work it enables. Maximum
three sentences.]

## Dependency metadata

- Depends on: none
- Execution: independent
- Provides foundation for: none
- Required parent state: none

## Scope

- [ ] [Concrete deliverable]
- [ ] [Concrete deliverable]

## Ownership boundaries

### Owned

- [Writable path or semantic area]

### Read-only / reference

- [Reference path or area]

### Do not touch

- [Explicit boundary]

## Interfaces and contracts

[Locked API/type/data/error/loading contracts needed by independent tasks, or
`None`.]

## Acceptance criteria

- [ ] AC-01: [Observable, independently verifiable behavior]
- [ ] AC-02: [Observable, independently verifiable behavior]

## Required tests

| Acceptance | Required behavior/test |
| --- | --- |
| AC-01 | [Test or required behavior] |
| AC-02 | [Test or required behavior] |

## How to verify (manual)

- [ ] [Action a non-technical person can perform]
- [ ] You should see: **[expected result]**.
- [ ] If it is broken you will see: **[failure signal]**.

## Required checks

- [ ] Focused acceptance tests
- [ ] Affected regression tests
- [ ] Required type/lint/static checks
- [ ] `git diff --check`
- [ ] Required CI checks are green

## Out of scope

- [Adjacent work that must not be absorbed]

## Escalation rules

Resolve autonomously:
- syntax/type errors
- lint/format failures
- ordinary failing tests
- implementation choices covered by existing patterns
- framework/API documentation lookup
- mechanical refactors required by acceptance criteria

Escalate when:
- acceptance criteria contradict each other
- required behavior changes shared architecture
- writable ownership overlaps another active worker
- satisfying this PR changes a dependency's contract
- multiple valid choices materially affect future PRs
- a required test cannot be meaningful without changing the specification

## Ready-state rules

- [ ] Every acceptance criterion is satisfied.
- [ ] Every required acceptance test passes.
- [ ] Affected regression tests pass.
- [ ] Required lint/type/static checks pass.
- [ ] Required runtime/integration checks pass.
- [ ] Required CI checks are green.
- [ ] No known in-scope blocker remains.
- [ ] No acceptance test was weakened to accommodate the implementation.
- [ ] The final diff stays inside this PR's scope.
- [ ] Worker completion report is present.
- [ ] Self-audit is complete.

## Worker completion report

Pending implementation.

When implementation completes, include:

- Parent route/model and reasoning effort
- Parallel task shards and exclusive ownership
- Which executor completed each shard
- Replacement/fallback reason when applicable
- Concise implementation, files, acceptance, verification, ownership, and
  remaining-failure summary
````
