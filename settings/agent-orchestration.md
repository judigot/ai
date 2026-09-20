# Agent orchestration policy

This policy separates expensive original reasoning from specification and
implementation so model cost scales with the value of the work.

The canonical ladder is:

```text
Astra  = founder / ideator / rare architecture escalation
Terra  = spec compiler / technical lead / unattended coordinator
Luna   = implementation / tests / routine debugging
CI     = completion authority
```

The strongest model should contribute the fewest tokens. Lower-cost tiers expand
the idea into progressively more detailed, executable work.

## Role hierarchy

### Founder / ideator

- Interface: Codex CLI or another approved client that exposes the mapped model.
- Default model: `gpt-6-astra`.
- Default reasoning effort: `low`; increase only when the founder decision
  genuinely needs more reasoning.
- Behavior: follow `agents/founder-ideator.md`.
- Output is normally a 2-8 sentence pitch, not an FRD or implementation plan.
- Do not keep Astra resident during routine repository work.
- Re-enter this tier only for original product direction, novel architecture, or
  an unresolved material tradeoff escalated by Terra.

### Spec compiler / technical lead

- Default model: `gpt-5.6-terra`.
- Default reasoning effort: `medium`.
- Behavior: follow `agents/spec-compiler.md`.
- Own repository-aware planning, FRDs, PR shells, dependency graphs, ownership
  boundaries, TDD acceptance criteria, implementation briefs, and repeated
  specification-level failure diagnosis.
- This is the default coordination tier for unattended/sleep-and-forget work.

### Implementation worker

- Default model: `gpt-5.6-luna`.
- Default reasoning effort: `low`.
- Behavior: follow `agents/task-master.md`.
- Own the token-heavy work: repository search, code edits, tests, lint/type
  fixes, routine debugging, CI log analysis, and mechanical documentation.

The user may explicitly select another available model or reasoning effort for a
session. Explicit user choice wins for that session, but workers should still
follow the role boundaries unless the user asks to collapse tiers.

## Verified mappings

| Role | Route | Executable model ID | Reasoning | Status |
| --- | --- | --- | --- | --- |
| Founder / ideator | Codex CLI | `gpt-6-astra` | low by default | active |
| Spec compiler / technical lead | Codex CLI | `gpt-5.6-terra` | medium | active |
| Overnight coordinator | Codex CLI | `gpt-5.6-terra` | medium | active |
| Implementation worker | Codex CLI | `gpt-5.6-luna` | low | active |
| Implementation fallback | Codex CLI | `gpt-5.6-terra` | low | active |

These model IDs were verified in the local Codex model cache. Codex CLI supports
`--model`, `-c model=...`, `model_reasoning_effort`, `exec`, and managed
worktrees.

## Routes awaiting verification

| Route | Requested preference | Current state |
| --- | --- | --- |
| Cursor planning | Composer 2.5 Fast | Cursor CLI is not installed; model ID, Fast availability, authentication, and included-subscription use are unverified. |
| Cursor implementation | Composer 2.5 Fast → GPT-5.6 Luna Low → Grok 4.6 Low → Claude Sonnet 5 Medium | No executable IDs are configured until Cursor CLI and the account model list verify them. |
| OpenCode planning | Approved free planning model | OpenCode is not installed and no free model mapping has been approved. |
| OpenCode implementation | Approved free coding model mapping | Unconfigured. Discover exact free IDs with `opencode models --refresh --verbose`, present the ordered mapping, and obtain approval before adding it here. |
| Claude Code | Claude Code worker | Claude Code is not installed. It is not part of the default fallback chain. |

Do not use Auto routing, paid API access, paid credits, or overages without
explicit approval. Do not assume a subscription has a separate allowance when
reached through another tool.

## Routing

### Idea generation

Use the founder/ideator tier only when the task requires original product
direction, high-leverage architecture ideas, or a strategic decision.

Do not invoke Astra merely because a task is difficult. If the desired behavior
is already known, start at specification or implementation.

Founder output should be short and then leave the active context.

### Specification

Use Terra for repository-aware planning and compilation of ideas into executable
contracts.

Terra may:

- inspect the repository;
- write FRDs;
- create/update PR shells;
- construct dependency DAGs;
- define ownership boundaries;
- map acceptance criteria to tests;
- prepare Luna worker briefs;
- diagnose repeated failures that suggest a bad/underspecified contract.

Terra should not perform routine implementation while an eligible Luna route is
available.

### Unattended coordination

Use Terra with `agents/overnight-orchestrator.md` and
`skills/sleep-and-forget/SKILL.md`.

The coordinator builds the PR-shell DAG, chooses parallel/stacked/sequential
execution, delegates to Luna, monitors concise verification state, and
checkpoints blockers. Astra is not the default overnight orchestrator.

### Implementation

1. Use `gpt-5.6-luna` at low reasoning for bounded implementation workers.
2. Prefer one-shot execution for implementation-ready PR shells: one isolated
   runner/process per PR, with the PR shell as durable state instead of a
   persistent model conversation.
3. If Luna is unavailable or its eligible pool is exhausted, use the approved
   implementation fallback, currently `gpt-5.6-terra` at low reasoning.
4. Use another provider only when its route is verified and approved below.

For a healthy Luna route, use this executor-local retry chain before escalating
to another model:

```text
Luna-low parent for one PR
  ↓
worker A: fresh Luna-low subagent
  ↓
verify filesystem/diff against the locked scope
  ↓ incomplete
worker B: fresh Luna-low subagent with the same task
  ↓
verify filesystem/diff again
  ↓ still incomplete
same Luna-low parent completes the bounded task
  ↓
trusted workflow verification / CI
```

Rules:

- Worker B is a new subagent thread; do not continue worker A.
- A worker's text response is not proof of completion. The filesystem, Git diff,
  ownership contract, acceptance criteria, and required checks are the source
  of truth after every attempt.
- The parent fallback must preserve the same writable ownership and acceptance
  criteria. It is not permission to broaden scope.
- Independent PRs may run this chain concurrently on separate isolated runners.
  Do not put multiple write-capable PR workers in one shared checkout.
- Subagents are an implementation detail inside one PR; PR-level parallelism is
  the primary concurrency boundary.
- If worker A, worker B, and the Luna parent all fail for a quality/specification
  reason, use the normal escalation ladder below.
- If the Luna route itself is unavailable or quota/auth prevents execution,
  skip the executor-local chain and use the model-route fallback rules below.

Retry a model-specific transient failure at most twice before trying the next
eligible model in the same role. A shared-pool exhaustion skips every model in
that pool. Authentication failures require reauthentication and a different
eligible route; never move credentials between tools.

Test failures, ambiguity, and poor output are quality failures, not quota
failures. Route them according to the escalation ladder instead of pretending
the model is unavailable.

### Escalation ladder

```text
Luna
  ↓ ordinary failure
Luna retry / focused debugger
  ↓ repeated spec-level failure
Terra
  ├─ repair worker brief → Luna
  ├─ repair PR contract → Luna
  └─ material founder/architecture decision → Astra
```

Do not escalate to Astra for syntax errors, test debugging, lint, framework
documentation, repository search, ordinary refactors, or CI log analysis.

Recheck a higher-priority unavailable route only at a later task boundary after
access is known to be restored. Let healthy workers finish.

## Model economy

Treat expensive-model tokens as a scarce architectural resource.

- Astra should receive the smallest sufficient context and return the shortest
  useful decision.
- Do not send Astra worker transcripts, repository-wide scans, CI logs, routine
  diffs, or implementation details.
- Terra should consume concise founder pitches and produce complete contracts.
- Luna should consume complete contracts and do the token-heavy execution.
- Prefer Git diffs, test summaries, and PR-shell completion reports over replaying
  worker conversations to a higher tier.
- Skip tiers when input is already mature: a valid PR shell goes directly to
  unattended coordination/implementation; a locked task goes directly to Luna.

## Worker contract

Use workers only for bounded tasks. Every planning report includes the
objective, assumptions, affected files and dependencies, steps, bounded tasks
with file ownership, dependency order, acceptance criteria, required checks,
risks, and escalation points.

Every implementation brief includes the objective, owned files, constraints,
non-goals, acceptance criteria, required checks, and the expected concise
report. Keep trivial work with the orchestrator. Parallelize only independent
work in isolated worktrees with non-overlapping ownership.

Before delegating, tell the user which route/model is being used and show a
concise worker brief: objective, owned scope, constraints, and expected output.
Do not repeat inherited conversation context or duplicate long prompts in the
user-facing announcement.

The orchestrator inspects partial changes before replacement, preserves valid
work, and reviews the final diff and verification evidence.

## PR shell orchestration

Use `settings/pr-shell.md` for implementation work that is specified before it
is executed, delegated across model tiers, or coordinated across multiple PRs.

A valid PR shell is the worker contract. The orchestrator must parse its
`depends_on`, `execution`, `base`, ownership boundaries, acceptance criteria,
required checks, escalation rules, and ready-state rules before delegation.

For multiple shells:

1. build a dependency DAG and reject cycles;
2. derive reverse dependencies instead of storing duplicate dependency metadata;
3. identify executable nodes from dependency state;
4. check writable ownership before parallel execution;
5. run independent non-overlapping work concurrently in isolated worktrees;
6. run overlapping work sequentially;
7. allow stacked work only after the parent is pushed and satisfies its declared
   parent gate;
8. keep implementation PRs draft until the shell's ready-state rules pass.

Execution follows the dependency graph, not PR-number order. The orchestrator
owns state transitions to `ready`; workers may update progress through
`verification`.

## Durable handoff

For long-running work, keep a handoff artifact in the target repository or its
approved task system. Record the objective, approved decisions, orchestrator,
active route, plan, task and worktree ownership, completed changes, verification
evidence, route failures, remaining work, and next action. If the orchestrator
cannot continue, checkpoint this artifact before handing off.

## Model maintenance

Mappings change only after official evidence shows a mapped model is retired,
deprecated, incompatible, unavailable, or no longer free. A newer model alone
does not justify replacement. Present the official evidence and exact proposed
replacement, then ask for approval before changing this file or tool-specific
configuration.

## Tool configuration

- Codex CLI reads `$CODEX_HOME/config.toml`; its default is configured there,
  not copied into product repositories. An explicit main-chat selection
  overrides that default for its session.
- Cursor CLI supports `~/.cursor/cli-config.json` and project
  `.cursor/cli.json`. Configure it only after the CLI and model availability are
  verified.
- Claude Code and OpenCode retain their own supported configuration locations.
  Do not copy credentials or MCP authentication payloads between them.
- Each client needs its own MCP configuration even when servers are shared.
