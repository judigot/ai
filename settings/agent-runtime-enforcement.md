# Agent runtime enforcement status

This document distinguishes controller guarantees from model instructions and
observed/automated evidence for unattended one-shot PR implementation.

Use it with settings/agent-orchestration.md, settings/pr-shell.md,
settings/repository-pr-contracts.md, and skills/sleep-and-forget/SKILL.md.

The optimization target is wall-clock time from implementation start to a
verified PR that satisfies its required gate. Agent count is not a success
metric.

## Status vocabulary

### ENFORCED

Trusted controller/workflow code rejects or prevents violations without relying
on the model to voluntarily comply.

### INSTRUCTED

The Luna parent/worker contract tells the model to behave this way, but the
trusted controller does not yet independently observe every internal scheduling
event.

### VERIFIED

A deterministic test or recorded execution demonstrates the behavior.

A rule may be both ENFORCED and VERIFIED.

## ENFORCED today

### Batch preflight before model spend

The one-shot controller validates the complete requested batch before restoring
Codex authentication or starting a model session.

For the first enforcement milestone, the runtime intentionally accepts only
already-executable independent PRs. It rejects rather than partially supports:

- incomplete PR-shell contracts;
- non-draft or closed PRs;
- fork PR heads;
- non-planned shells;
- sequential, stacked, or foundation execution;
- non-empty dependencies;
- dependency cycles detected inside the requested batch;
- a contract base that disagrees with the actual PR base;
- independent PRs not based on the repository default branch;
- overlapping machine-readable ownership;
- missing or invalid machine-readable ownership.

A later scheduler may add dependency-ready stacked/sequential execution. Until
that implementation exists, rejecting unsupported arrangements is the safety
contract.

### Machine-readable ownership

Parallel unattended execution requires an agent-pr touch_set.

The parser:

- preserves legitimate dotfiles and dot-directories exactly;
- does not treat github/ as ownership of .github/;
- does not treat env as ownership of .env;
- rejects empty entries;
- rejects absolute paths;
- rejects ./ ambiguity;
- rejects traversal components;
- rejects backslash separators;
- rejects globs;
- rejects duplicate touch_set declarations;
- distinguishes missing ownership from invalid ownership.

Invalid ownership fails closed. The final trusted diff is checked against the
same ownership before publication.

### Controller-wide implementation budget

The implementation workflow uses a conservative global dispatch semaphore.
Only one implementation dispatch may consume model capacity at a time.

Within the active dispatch:

~~~text
max active PR runners
  <= floor(global_model_budget / (1 + max_workers_per_pr))
~~~

This is a reservation upper bound, not a target. A PR parent is still instructed
to use fewer or zero subagents when additional workers would not shorten
readiness time.

Each target PR also has a repository/PR-specific concurrency group to prevent
duplicate implementation jobs for the same PR.

CI readiness is monitored by a separate workflow and therefore does not keep the
implementation dispatch/model semaphore occupied.

### Dependency bootstrap before Codex

The trusted runner prepares target-project dependencies before the
network-disabled model session.

Controller toolchain pins currently include:

- Node.js 24.21.0
- Bun 1.4.2

Dependency installation uses the detected frozen lockfile. Package-manager
download caches are reused where available.

The trusted setup runs without publishing credentials and performs a cheap
project test-runner smoke check before Codex starts. Unsupported or ambiguous
lockfile layouts fail before model spend.

The model session itself keeps workspace-write network access disabled.

### Structured implementation outcomes

The PR parent must return one machine-readable state:

~~~text
implemented
blocked
failed
~~~

The trusted runner parses the result. Invalid/non-JSON output becomes failed;
prose cannot accidentally count as completion.

Implemented may proceed to normal publication only when:

- the structured state is implemented;
- repository changes exist;
- no model-created staged changes exist;
- every changed path remains inside machine-readable ownership;
- git diff --check passes;
- the PR head still equals the preflight snapshot.

Blocked never becomes ready. Recoverable in-scope edits may be committed to the
still-draft PR as an explicit blocked checkpoint and receive a failing Agent
Workspace implementation status.

Failed is not published as implementation. The trusted runner preserves a
private compact result/recovery patch artifact and marks the implementation
status failed.

### Exact readiness

Publishing implementation and waiting for CI are separate execution phases.

The readiness monitor receives the exact pushed SHA and exact required check
names. It:

- checks both GitHub Check Runs and commit-status contexts;
- follows pagination;
- matches required names exactly;
- treats a missing required gate as unresolved;
- treats a skipped required gate as failure rather than implicit success;
- waits through pending/in-progress states;
- fails immediately on a failed required gate;
- repeatedly confirms the PR remains open and the exact pushed SHA remains its
  head;
- succeeds only when every required name is successful on that SHA.

For judigot/scaffolder, PR Gate is always included as a canonical required
readiness gate.

Branch-protection required contexts are used when the integration can read
them. Repository adapter metadata or explicit controller input supplies exact
names when branch-protection metadata is unavailable.

## INSTRUCTED today

These behaviors are encoded in the Luna-low PR-parent/leaf-worker protocol, but
the trusted controller does not yet independently observe all internal subagent
state transitions:

- parent inspects the relevant code once before fan-out;
- parent builds the smallest useful intra-PR task DAG;
- parent establishes interfaces/data shapes before dependent work;
- parent schedules critical-path-ready tasks rather than fixed waves;
- independent leaf workers may run concurrently;
- leaf workers receive exclusive editable ownership;
- workers do not spawn grandchildren;
- workers return ownership before reassignment;
- deterministic failures are repaired rather than reflexively replaced;
- unavailable/stalled/abandoned/repeatedly confused tasks get at most one fresh
  Luna-low replacement;
- one failed replacement leads to Luna-low parent takeover of that bounded task.

The final PR-level ownership boundary is enforced, but per-worker ownership
inside that boundary is not yet sandboxed by separate filesystem ACLs or
worktrees.

## VERIFIED today

Deterministic tests cover:

- exact dotfile ownership behavior;
- invalid/missing ownership distinction;
- traversal/absolute/glob/empty ownership rejection;
- independent ownership overlap detection;
- dependency-cycle detection;
- incomplete-contract rejection;
- unsupported dependency-arrangement rejection;
- wrong stacked/base metadata rejection;
- exact required-check matching;
- missing canonical gate behavior;
- skipped required-check failure;
- commit-status readiness contexts;
- structured parent-result fail-closed parsing;
- dependency-manager preflight detection.

Previous Agent Workspace experiments also demonstrated PR-level parallelism:
multiple isolated GitHub Actions PR runners entered Luna execution concurrently.

## Not yet runtime-verified

Do not describe these as proven scheduler guarantees yet:

- two intra-PR implementation workers actually overlapping in wall-clock time;
- a dependent intra-PR task starting only after its prerequisite completes;
- ownership transfer occurring only after the original worker has stopped;
- replacement-worker failure causing parent takeover;
- a blocked nested task being prevented from reaching ready state through the
  complete end-to-end path.

The next runtime-proof milestone should use a disposable/mock PR contract and
capture those cases explicitly.

## Execution evidence

Trusted controller timestamps such as parent start/end, Git SHAs, workflow/job
timing, publication state, and CI readiness are runtime evidence.

The Luna parent also returns compact task-event records:

~~~text
task id
owner
dependencies
event
replacement reason
check result
~~~

Those task events are currently model-reported evidence, not independent
controller instrumentation. Preserve that label in reports.

Future instrumentation should prefer native/runtime subagent lifecycle events if
the execution surface exposes them reliably.

## Metrics

Measure at least:

~~~text
implementation dispatch start
PR parent start/end
publication time
required CI ready time
blocked/failed time
replacement count
parent-takeover count
~~~

Derived metrics:

~~~text
time-to-publish
CI wait time
time-to-verified-PR
model-active time
repair/retry time
~~~

Raise concurrency only when measured time-to-verified-PR improves without
raising integration/recovery failures.
