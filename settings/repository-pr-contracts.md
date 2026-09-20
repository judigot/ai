# Repository PR contracts

Some target repositories enforce machine-readable pull-request metadata in CI.
Before creating or updating a PR, inspect the target repository's current PR
template and PR CI workflow. Repository-local metadata is part of the delivery
contract and must agree with this overlay's PR-shell dependency and ownership
plan.

Do not maintain two contradictory sources of truth. Derive repository-local PR
metadata from the PR shell.

## Scaffolder

`judigot/scaffolder` uses this block in agentic feature PRs:

```text
<!-- agent-pr
depends_on: none
stacked_on: main
touch_set: src/example/,files/Projects/hono-react/
-->
```

Map the PR shell to this block:

- `depends_on`: actual prerequisite PR numbers, or `none`.
- `stacked_on`: `main` when no prerequisite is still open; otherwise the one
  immediate open prerequisite PR.
- `touch_set`: the smallest repository path prefixes covering the shell's
  writable ownership. Use path prefixes, not globs.

Scaffolder PR CI enforces:

- every changed file must be inside the declared `touch_set`;
- independent open PRs must not have overlapping touch sets;
- a PR with an open dependency must target that dependency's head branch;
- only one dependency may remain open for a stacked PR;
- after the prerequisite merges, retarget the child to `main` and change
  `stacked_on` to `main`;
- `PR CI / PR Gate` is the stable PR merge-readiness signal.

Do not bypass ownership failures by widening `touch_set` to a shared root such
as `src/` unless the PR genuinely owns that whole root. Resolve the dependency
DAG or split ownership instead.

### Scaffolder production safety

Fast PR CI and strict production CI serve different goals. Optimize PR checks for
iteration speed, but never trade production safety for that speed.

Every automatic Scaffolder production deployment from `main` is fail-closed.
The canonical production pipeline must run the business-critical validation jobs
in parallel and deploy only after all of them pass for the same `main` SHA:

- lint and template lint;
- Bun tests;
- Vitest;
- Playwright;
- full Golden Frameworks regression;
- `/api/hello` under both Node.js and Bun.

The Vercel deploy job must:

- depend explicitly on all required production checks rather than polling their
  status or duplicating them inside the deploy job;
- check out the exact SHA that passed validation;
- verify that SHA is still the current `main` tip before production build and
  again immediately before deployment;
- cancel/refuse stale deployments when a newer `main` commit exists;
- verify production `/api/hello` after deployment and confirm the deployed SHA.

A failure, cancellation, or missing required production check means **do not
deploy**. Do not weaken this gate merely to reduce waiting time.

Standalone test workflows may remain reusable/manual for diagnostics, but they
must not create duplicate automatic `main` executions when the production
pipeline already calls them.

Legacy or secondary deployment paths must not bypass the canonical production
gate. In Scaffolder, the legacy EC2 deployment is manual-only; Vercel
`Production CI/CD` is the single automatic production path.

## Agent responsibilities

### Spec compiler / orchestrator

- inspect the repository-local PR contract before opening shells;
- generate repository metadata from the shell rather than asking a worker to
  invent it;
- reject overlapping independent ownership before implementation starts;
- stack dependent PRs on their immediate open prerequisite;
- update repository metadata when a parent merges or ownership legitimately
  changes.

### Implementation worker

- change only files inside the declared writable ownership;
- do not silently widen ownership;
- report required ownership expansion to the coordinator;
- treat the repository's stable PR gate as the final PR readiness signal when
  CI defines one.

### Stacked PR lifecycle

```text
parent PR open
    ↓
child targets parent branch
stacked_on: #parent
    ↓
parent merges
    ↓
child retargets main
stacked_on: main
    ↓
rerun PR Gate
```
