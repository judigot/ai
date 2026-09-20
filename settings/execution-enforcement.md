# One-shot execution enforcement

Use this document to distinguish architecture intent from trusted runtime
guarantees.

Status meanings:

- ENFORCED — trusted controller/workflow code prevents the invalid state.
- INSTRUCTED — the model is told to behave this way, but trusted code does not
  own the scheduling primitive.
- VERIFIED — deterministic tests or live run evidence demonstrate the behavior.

## Current hardened executor

The current Agent Workspace one-shot executor initially accepts only
implementation-ready, dependency-free independent PRs. This is intentionally
narrower than the full sleep-and-forget dependency policy.

| Behavior | Status |
| --- | --- |
| PR description is complete before model execution | ENFORCED + VERIFIED |
| Missing and invalid ownership are distinct | ENFORCED + VERIFIED |
| Dotfiles such as .github and .env preserve their exact paths | ENFORCED + VERIFIED |
| Absolute paths, traversal and malformed ownership stop execution | ENFORCED + VERIFIED |
| touch_set globs and duplicate touch_set declarations are rejected | ENFORCED + VERIFIED |
| Unattended one-shot PRs must remain draft until implementation/readiness completes | ENFORCED + VERIFIED |
| Independent PRs must target the repository default branch | ENFORCED + VERIFIED |
| Dependency cycles in the requested batch are rejected before unsupported dependency execution is reported | ENFORCED + VERIFIED |
| Requested independent PRs cannot have overlapping writable ownership | ENFORCED + VERIFIED |
| Dependent/sequential/stacked/foundation batches are rejected by this initial executor | ENFORCED + VERIFIED |
| Dependencies and a real baseline test are prepared before network-disabled Codex execution | ENFORCED + VERIFIED |
| Setup/preflight must leave no unignored worktree changes | ENFORCED + VERIFIED |
| Codex auth refresh is serialized before parallel PR fan-out | ENFORCED |
| Parallel PR runners never persist refreshed Codex auth | ENFORCED |
| Parent must return implemented, blocked or failed | ENFORCED + VERIFIED |
| Blocked/failed results do not proceed to normal publishing | ENFORCED |
| Agent Workspace implementation commit-status reporting is best-effort and non-authoritative | ENFORCED |
| Recoverable result/diff checkpoint is preserved before failure is surfaced | ENFORCED |
| Normal commit/push is gated on structured state=implemented regardless of status-reporting success | ENFORCED |
| Final changed paths must stay inside preflight ownership | ENFORCED |
| Required readiness contexts must appear on the exact pushed SHA | ENFORCED + VERIFIED |
| Required skipped/failed contexts cannot become ready | ENFORCED + VERIFIED |
| Check runs and legacy commit-status contexts are both evaluated | ENFORCED + VERIFIED |
| CI waiting is separated from implementation capacity | ENFORCED |
| Concurrent one-shot controller dispatches are currently globally serialized | ENFORCED |
| PR parent creates the intra-PR task DAG | INSTRUCTED |
| Parent schedules critical-path work first | INSTRUCTED |
| Useful leaf slots refill immediately | INSTRUCTED |
| Leaf workers have exclusive edit ownership | INSTRUCTED + telemetry validation, with final PR-scope enforcement |
| Workers do not spawn grandchildren | INSTRUCTED |
| Replacement starts only after prior owner stops | INSTRUCTED + telemetry validation |
| Dependent shard starts only after prerequisite ends | INSTRUCTED + telemetry validation |
| Independent Luna workers actually overlap in live execution | NOT YET VERIFIED |
| Failed replacement requires a later completed parent-takeover shard in an implemented trace | ENFORCED on model-reported telemetry + VERIFIED by unit tests |
| Replacement failure actually causes parent takeover in live execution | NOT YET VERIFIED |

Structured shard telemetry is model-reported. The trusted validator rejects
internally inconsistent chronology, dependency order, replacement transfer,
concurrent editable-path overlap, and an implemented result that records a
failed replacement without a later completed parent takeover. It still does not
independently observe Codex subagent scheduling. Do not label nested scheduling
VERIFIED until a live smoke run supplies execution evidence.

## Contract requirements for hardened one-shot execution

A PR intended for the current one-shot executor must have:

- Goal or Objective;
- dependency metadata with no active dependencies;
- execution=independent;
- base matching the actual PR base;
- Ownership boundaries;
- Interfaces and contracts;
- Acceptance criteria;
- Required checks;
- Out of scope;
- machine-checkable writable paths.

Repository-specific touch_set metadata is preferred when available.

For touch_set, every entry must be a literal repository-relative path prefix.
Globs are invalid and the agent-pr block may contain exactly one touch_set
declaration. Leading dots are significant.

Without touch_set, every machine-checkable item under Ownership boundaries /
Owned must be an explicit repository path wrapped as inline code. Semantic areas
may still appear elsewhere for human explanation, but they do not satisfy
parallel ownership enforcement.

The broader PR-shell contract may describe sequential, stacked, and foundation
work. Those remain valid planning states, but the hardened executor must reject
them until the trusted top-level dependency scheduler is implemented.

## Codex authentication fan-out

Codex account authentication must be refreshed and persisted once before a
parallel PR batch fans out. Do not let parallel PR runners race a rotating
refresh token.

The trusted controller must:

1. preflight the requested PR batch before spending model tokens;
2. run one serialized authenticated Codex refresh/persistence check;
3. start implementation in a new workflow/run boundary so workers receive the
   refreshed repository-secret snapshot;
4. let parallel PR runners read that auth snapshot without writing it back.

Never transport `auth.json` through artifacts, ordinary outputs, logs, or PR
content. If the refresh token has already been used and cannot refresh, stop
before implementation and require a fresh trusted `codex login` plus reseeding
of the existing Codex auth secret.

## Recovery semantics

Retry the unfinished task, not the entire PR.

Within a PR:

1. preserve useful edits;
2. repair deterministic failures in place;
3. replace only unavailable, stalled, abandoned, or repeatedly confused work;
4. stop the original owner before transferring ownership;
5. give one fresh Luna-low replacement only the remaining task plus evidence;
6. if that replacement fails, the Luna-low parent takes over the bounded task or
   reports a blocker.

For one-shot execution, a blocked or failed parent does not partially publish
the PR branch. The trusted runner preserves a recovery checkpoint and reports
the state. The structured result plus workflow/job outcome is authoritative;
optional commit-status reporting is supplemental and must not control whether
partial work is publishable. Partial publishing requires a separate explicit
checkpoint policy; it must never be interpreted as ready.

## Readiness semantics

Implementation completion and PR readiness are separate states.

The implementation runner should release model capacity immediately after a
verified push. A separate readiness monitor waits for the exact repository
contexts required for the exact pushed SHA and repeatedly confirms that SHA
remains the PR head.

An early lint success is not readiness when the required PR gate has not appeared.

## Verification promotion

Before promoting an INSTRUCTED scheduling rule to VERIFIED, capture a small
end-to-end run showing the relevant event sequence, including task IDs, owners,
dependencies, start/end times, replacement reason, and checks.

The first hardened smoke proved batch preflight and concurrent isolated PR-runner
startup, but the model parents stopped before implementation because the stored
Codex refresh token had already been rotated. That is not evidence of nested
worker scheduling. Repeat the smoke only after a fresh trusted Codex login is
reseeded and the serialized auth-refresh boundary succeeds.

The next smoke milestone should demonstrate:

1. two independent leaf workers overlap;
2. a dependent task starts only after its prerequisite;
3. ownership transfer begins only after the original owner stops;
4. a replacement failure leads to parent takeover;
5. blocked work never reaches ready/published state.
