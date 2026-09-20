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

Runtime enforcement status is tracked in `settings/execution-enforcement.md`.
Do not describe an INSTRUCTED scheduling rule as controller-enforced or verified.

The current hardened Agent Workspace one-shot executor intentionally accepts only
complete, dependency-free independent PRs. Sequential, stacked, foundation, and
dependency-aware scheduling remain valid orchestration policy, but the executor
must reject those arrangements until the trusted dependency scheduler supports
them.

1. Use `gpt-5.6-luna` at low reasoning for bounded implementation work.
2. Prefer one-shot execution for implementation-ready PR shells: one isolated
   runner/process per PR, with the PR shell as durable state instead of a
   persistent model conversation.
3. Use two levels of parallelism:
   - across PRs: independent non-overlapping PRs run concurrently;
   - inside one PR: one Luna-low parent may schedule bounded Luna-low leaf
     workers for independent implementation tasks.
4. Optimize for wall-clock time until a verified PR is ready, not for worker
   count. Spawn workers only when independent work is ready and useful.
5. If Luna is unavailable or its eligible pool is exhausted, use the approved
   implementation fallback, currently `gpt-5.6-terra` at low reasoning.
6. Use another provider only when its route is verified and approved below.

#### PR parent responsibilities

The Luna-low parent owns the implementation schedule for one PR.

Before spawning workers, it:

1. reads the PR contract and applicable repository instructions;
2. inspects the relevant code once;
3. builds the smallest useful intra-PR task DAG;
4. locks shared interfaces/data shapes before dependent tasks start;
5. assigns exclusive writable ownership for every concurrent task;
6. identifies the critical path and ready queue.

Split by independently verifiable behavior, not mechanically by file count.
One file per worker is appropriate only when that file is a meaningful
independent task. Group tightly coupled files.

Every worker handoff includes:

- exact objective;
- exclusive editable files/directories;
- relevant existing code and conventions already discovered by the parent;
- interfaces/data shapes it must consume or implement;
- completion criteria;
- targeted checks safe to run concurrently;
- explicit instruction that it is a leaf worker and may not spawn subagents.

Workers may read any relevant file. Editing outside assigned ownership requires
reassignment by the parent. If two tasks must edit the same file, combine them
or run them sequentially.

#### Scheduling policy

Start critical-path work before isolated polish. Do not use fixed waves.

When a worker completes, the parent inspects the actual diff and immediately
assigns any newly ready high-priority task when a worker slot would shorten PR
readiness time. The parent may integrate parent-owned files while workers
continue on exclusive paths.

Use this starting worker heuristic, not as a claimed optimum:

| PR shape | Implementation workers |
| --- | ---: |
| Small, tightly coupled change | parent only |
| Two independent components | up to 2 |
| Several independent components | up to 3 |
| Broad change with clear ownership | up to 4 |

Keep a controller-wide budget for active model work and expensive tests. A
conservative implementation may reserve `1 + max_workers_per_pr` model slots
for each active PR runner and derive PR concurrency from the global budget.
Measure throughput before increasing limits.

Workers never spawn grandchildren. Scheduling remains visible to the PR parent
and top-level controller.

#### Shared-worktree rules

Each PR has its own isolated branch and checkout/worktree. Workers within that
PR may share the checkout only with strict exclusive file ownership.

Leaf workers must not:

- stage, commit, push, switch branches, or merge;
- install dependencies or edit lockfiles;
- run migrations or code generation;
- run repository-wide formatters;
- mutate shared configuration or other shared state;
- edit outside assigned ownership.

Shared types/contracts, route registration, package/lock files, migrations,
generated manifests, and integration files should normally remain parent-owned.
The parent/trusted runner owns Git publishing and shared-state operations.

Workers run targeted checks that are safe beside concurrent edits. The parent
runs integration checks against a stable snapshot.

#### Task-level recovery

Retry the unfinished task, not the whole PR.

After a worker returns, inspect the filesystem/diff and check output. Preserve
valid changes.

- A deterministic test failure normally calls for repairing the existing work,
  not replacing the worker.
- Use a replacement only for unavailable, stalled, abandoned, or repeatedly
  confused execution.
- Stop/finish the original worker and confirm ownership returned before
  reassignment.
- Give one fresh Luna-low worker the failure evidence, current repository state,
  and only the remaining bounded task.
- If that fresh replacement also fails, the same Luna-low parent takes over the
  bounded task or reports a concrete blocker.

A worker's text response is never proof of completion. The filesystem, Git diff,
ownership contract, acceptance criteria, and required checks are the source of
truth.

The parent fallback must preserve the same writable ownership and acceptance
criteria. It is not permission to broaden scope.

After integration, the parent/trusted workflow runs the required PR checks.
CI and the repository's stable PR gate remain the final readiness authority.

If the Luna route itself is unavailable or quota/auth prevents execution, skip
task-level recovery and use the model-route fallback rules below.

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

For a PR-level one-shot parent, each leaf implementation handoff includes the
exact objective, exclusive editable paths, relevant context already discovered
by the parent, required interfaces/data shapes, completion criteria, targeted
checks, and a no-grandchildren instruction.

Leaf workers may inspect dependencies and surrounding code, but they do not own
Git publishing or shared-state commands. See `agents/task-master.md` leaf mode.

Keep trivial/tightly coupled work with the PR parent. Parallelize only
independent tasks with non-overlapping writable ownership.

Before delegating, tell the user which route/model is being used and show a
concise worker brief: objective, owned scope, constraints, and expected output.
Do not repeat inherited conversation context or duplicate long prompts in the
user-facing announcement.

The orchestrator/parent inspects partial changes before replacement, preserves
valid work, continuously integrates completed shards, and reviews the final diff
and verification evidence.

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
