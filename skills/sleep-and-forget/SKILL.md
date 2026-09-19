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

Each worker gets:

- one PR/worktree;
- goal;
- owned paths/areas;
- do-not-touch boundaries;
- acceptance criteria;
- required tests/checks;
- parent gate;
- concise completion-report format.

Workers follow `skills/tdd-ci/SKILL.md`.

Default maximum: three concurrent implementation workers.

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
