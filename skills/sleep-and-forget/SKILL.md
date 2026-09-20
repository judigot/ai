---
name: sleep-and-forget
description: Use this skill for unattended or overnight implementation where the user wants to stop babysitting and return to completed PRs. Convert ideas/specs into PR shells when needed, build a dependency DAG, run safe work in parallel or sequence, delegate implementation to low-cost workers, and checkpoint all progress.
---

# Sleep and Forget

Use this workflow when the user says they want to sleep, leave, stop
babysitting, run work unattended, or wake up to finished PRs.

The workflow optimizes for maximum correct progress per expensive-model token.

## Model ladder

Canonical roles are defined in `settings/agent-orchestration.md`:

```text
Astra  = founder / original ideation / rare architecture escalation
Terra  = spec compiler / technical lead / overnight coordinator
Luna   = implementation / tests / routine debugging
CI     = completion authority
```

Do not keep Astra resident during implementation.

## Input modes

### Existing valid PR shells

If valid PR shells already exist, skip founder ideation and specification
generation. Start from dependency analysis.

### Concrete requirement without a PR shell

Use the spec-compiler tier to create implementation-ready PR shells.

### Raw product idea

Use the founder-ideator tier once to produce a short pitch. Then immediately
hand the pitch to the spec-compiler tier. Do not ask Astra to expand the pitch
into an FRD.

## Credit-saving PR-shell preflight

When a planning chat with GitHub write access is available (for example,
ChatGPT with the GitHub connector), prefer creating the draft PR shells there
before starting the Codex implementation session.

The preflight chat should:

1. create only the branch/planning artifact required to open the shell;
2. put the complete implementation contract in the PR description;
3. create parent/foundation shells first so child dependencies can use real PR
   numbers;
4. leave every shell draft and implementation-empty;
5. hand the PR URLs/numbers to the unattended coordinator.

Do not duplicate the same planning work in Codex after valid shells exist.
If no external planning chat can write GitHub, Terra/spec-compiler may create
the shells from the Codex environment instead.

## PR-shell stage

Follow `settings/pr-shell.md`.

When GitHub writes are available, persist the plan as draft PR shells so the
queue survives model/session interruption.

A shell contains the contract, not the implementation.

For multiple shells:

1. create parents/foundations first;
2. use actual PR numbers in child `depends_on`;
3. set execution to independent, sequential, stacked, or foundation;
4. set ownership boundaries;
5. define stable acceptance criteria and required checks;
6. leave `state: planned` until execution begins.

## Dependency scheduler

Build a directed acyclic graph from `depends_on`.

Reject cycles before implementation.

A node is executable only when its parent gate is satisfied.

### Independent

Run concurrently if writable ownership does not overlap.

### Foundation

Finish and push the shared foundation first, then fan out children.

### Stacked

A child may begin before its parent merges when:

- the parent implementation is committed and pushed;
- the parent's focused checks are green;
- the declared parent branch is the child's base;
- the coordinator considers the parent contract stable enough.

Propagate later parent fixes into descendants with non-destructive merges.
Do not rebase pushed/shared branches or force-push merely to maintain the stack.

### Sequential

Run after dependencies when tasks overlap or require the parent's completed
behavior.

## Worker execution

Delegate implementation-ready shells to Luna using `agents/task-master.md`.

Prefer one-shot PR execution when the PR shell is complete. The durable state is
the PR description, branch, commits, and CI; a persistent model conversation is
not required.

Use two levels of parallelism:

1. independent PRs run concurrently in isolated runners/processes;
2. each active PR gets one Luna-low parent that may schedule useful independent
   Luna-low leaf workers inside that PR.

The optimization target is **time until a verified PR is ready**, not number of
agents running.

### PR parent

The parent reads the PR contract, inspects relevant code once, establishes shared
interfaces/data shapes, then builds an intra-PR task DAG.

Split implementation by independently verifiable behavior with exclusive
editable ownership. One file per worker is appropriate only when that file is a
meaningful independent task. Group tightly coupled files.

Every leaf-worker handoff contains:

- exact objective;
- exclusive editable files/directories;
- relevant code/conventions already discovered by the parent;
- interfaces/data shapes it consumes or implements;
- completion criteria;
- targeted checks safe beside concurrent work;
- explicit instruction not to spawn subagents.

Workers may read any relevant file. If two tasks need the same file, combine
them or run them sequentially.

### Critical-path scheduling

Do not run fixed waves.

Start tasks that unlock other work first. As soon as a worker finishes, the
parent reviews its actual changes and immediately assigns a newly ready
high-priority task when a slot would shorten PR readiness time.

Use this initial sizing heuristic:

| PR shape | Workers |
| --- | ---: |
| Small/tightly coupled | parent only |
| Two independent components | up to 2 |
| Several independent components | up to 3 |
| Broad with clear non-overlapping ownership | up to 4 |

This is a starting policy, not a claimed optimum.

The top-level controller also keeps a global active-model/test budget so many
PRs cannot each multiply into unbounded subagents. Refill controller capacity as
PR runners complete. Measure throughput before raising limits.

### Shared-worktree ownership

Each PR has its own branch and checkout/worktree. Within that PR, leaf workers
may share the checkout only with strict exclusive file ownership.

Leaf workers do not:

- commit, push, merge, stage, or switch branches;
- install dependencies or edit lockfiles;
- run migrations/code generation or repo-wide formatters;
- mutate shared configuration/state;
- edit outside assigned ownership.

The PR parent/trusted runner owns Git publishing, shared types/contracts,
integration files, package/lock changes, migrations, generators, and other
shared-state operations unless one is explicitly assigned to a single worker
with no collision risk.

Workers run targeted checks that are safe beside concurrent edits. The parent
runs integration checks on a stable snapshot.

### Recovery

Retry the unfinished task, not the entire PR.

After every worker return, inspect the actual filesystem/diff and check output.
Preserve useful edits.

- Deterministic test failures normally get repaired in place.
- Replace only unavailable, stalled, abandoned, or repeatedly confused workers.
- Stop/finish the original worker and return its ownership before reassignment.
- Give one fresh Luna-low replacement the failure evidence and remaining bounded
  task.
- If that replacement also fails, the same Luna-low parent takes over the
  bounded task or reports a concrete blocker.

A textual completion claim never overrides repository state.

After integration, the trusted workflow verifies scope, commits/pushes, and the
repository's CI/PR gate remains the completion authority.

Workers follow `skills/tdd-ci/SKILL.md`.

## Token economy

### Astra

Use only for:

- original high-leverage idea pitches;
- novel architecture direction;
- conflicting product invariants;
- material cross-system tradeoffs that Terra cannot resolve from existing
  contracts.

Founder output should normally be 2-8 sentences.

Do not send Astra:

- repository-wide scans;
- CI logs;
- worker transcripts;
- routine diffs;
- implementation details;
- lint/type/test failures.

### Terra

Use for:

- repository-aware specification;
- FRDs;
- PR shells;
- dependency DAGs;
- ownership planning;
- acceptance/TDD compilation;
- worker briefs;
- repeated implementation-failure diagnosis;
- unattended coordination.

Prefer concise diff/test summaries over full worker transcripts.

### Luna

Use for the token-heavy work:

- file discovery;
- coding;
- tests;
- lint/type fixes;
- ordinary debugging;
- CI log analysis;
- documentation mechanics;
- repetitive framework work.

## Autonomous behavior

Do not wake the user for routine implementation choices covered by the locked
contract or existing patterns.

If a blocker requires a new product decision:

1. checkpoint and push valid work;
2. mark the affected shell `blocked`;
3. continue independent DAG nodes;
4. use Terra to produce the smallest decision packet;
5. invoke Astra only when the decision is genuinely founder/architecture level.

Never invent secrets, bypass security controls, perform destructive git actions,
or merge to the default branch without authorization.

## Recovery

For quota/model/tool failures, preserve progress and move to the next eligible
route according to `settings/agent-orchestration.md`.

A worker/model failure is not permission to weaken tests or alter acceptance
criteria.

If a parent becomes unstable after descendants started, fix the parent first,
then update affected descendants and rerun their checks.

## Morning report

Report only useful status:

```text
Sleep-and-forget run

PR #N — READY | VERIFYING | BLOCKED
- implemented:
- checks:
- remaining:

Execution waves:
- Wave 1: ...
- Wave 2: ...

Escalations:
- Terra:
- Astra:

Unfinished blockers:
- exact blocker → exact next action
```

The objective is maximum durable progress, not pretending every PR finished.
