# Sprint integration contract

Use this contract when delivery PR shells accumulate on an integration branch
for QA before landing on the final target branch. Names such as `main`,
`develop`, or `sprint/...` follow the repository's conventions. The final target
need not be the default branch.

This is agent guidance, not a claim of runtime enforcement. Apply
[PR shell identity and readiness](pr-shell.md),
[repository PR contracts](repository-pr-contracts.md), and existing repository
checks. Do not bypass an executor that rejects dependent or stacked PRs.

## SI-01: Separate integration, landing, and deployment

Declare the integration branch, final target, one integration PR, and coordinator
before integration begins. The integration branch and PR serve integration and
QA. Only the integration PR lands this sprint on the final target, after explicit
user authorization or sign-off by an orchestrator with delegated merge authority.
Shell PRs land on the integration branch, not directly on the final target.

Deployment is a separate action requiring explicit user authorization, even for
shared development environments. Default to the repository's declared deployment
source, normally the final target; deploy an integration ref only when the user
explicitly names it. Record the approved environment and exact deployed SHA and
verify them after deployment. Passing QA does not authorize shipping.

## SI-02: Preserve one delivery path

Implementation stays on each shell's existing head branch and PR. Accumulate
those shells by merging them into the integration branch in `depends_on` order.
Do not create a duplicate cherry-pick path for the same slices.

An alternate integration strategy requires a documented orchestrator exception
within the user's approved scope. Before applying it, reconcile the original PR
contracts, dependency graph, and disposition of the shells so there is still one
authoritative delivery story. Retiring shells still requires explicit user
authorization under SI-04.

## SI-03: Derive the merge plan from shell metadata

Read every shell's `depends_on`, base, parent-state gate, ownership, and readiness
rules. Reject cycles, missing dependencies, and inconsistent bases before merging.
Execution follows the dependency DAG, not numerical PR order.

A child targets its immediate open parent's head branch until that parent lands
on the integration branch. The orchestrator then retargets the child to the
integration branch, synchronizes shell and repository-native metadata, reviews
the resulting diff, and reruns applicable checks. Repeat for each dependency.
Do not invent a second dependency plan in the integration PR.

## SI-04: Keep shells visible through delivery

Keep each shell open and draft until its ready-state rules pass. Integration
branch creation or local inclusion of its commits is not a reason to close it.
Close only when it has merged to its declared target or the user explicitly
retires duplicate/obsolete work. Prefer GitHub merges so the PR records its
actual merge target. Verify PR state after merging; a local merge alone does not
prove that GitHub has marked the shell merged.

## SI-05: Preserve published branch identity

Append implementation and cleanup commits to the existing shell head. Do not
rebase or force-push shared branches to improve diff appearance without explicit
user approval and orchestrator alignment. Existing destructive-command safeguards
in [rules.md](rules.md) still apply.

Before an approved rewrite, stop affected workers and preserve recoverable work.
After it, update affected PR descriptions, bases, dependency metadata, and worker
handoffs; reconcile their worktrees and rerun checks on the new heads before
resuming. Never leave a worker using a silently replaced shell tip.

## SI-06: Prefer traceability over history appearance

The coordinator owns retargeting and integration merges. Prefer GitHub merges
that show which PR landed on which branch. If an approved local merge is needed,
include the shell PR number in its merge message, push the integration result,
and reconcile GitHub PR state without pretending a closed PR was merged.

Report the current integration tip, final-target-to-integration compare link,
shell PR numbers, and verified merge status. Do not repeatedly linearize or
rewrite history merely for appearance. Distinguish integrated, checked, landed
on the final target, and deployed in completion reports.

## SI-07: Remove temporary planning artifacts before integration

The PR description holds the implementation specification. If a temporary file
was necessary to create a draft PR, remove it with a cleanup commit on the same
delivery branch before merging that shell into the integration branch. Keep
intentional repository documentation; remove only temporary placeholders.

Inspect both the shell diff and final-target-to-integration diff for planning-only
files, including repository-specific planned directories. If a placeholder has
already reached integration, remove it there before final-target merge and record
the correction. A file remaining in commit history is acceptable; it must be
absent from the resulting tree and delivery diff.

## SI-08: Keep the integration PR concise and current

Its body identifies the final target, integration branch, canonical dependency
or stack reference, shell merge order derived from the DAG, compare URL, QA
checks, and authorization boundaries. State that shells merge into integration
and the integration PR is the only path to the final target. Keep any required
repository-native metadata synchronized with the shells.

Avoid manually maintained per-commit SHA tables. Use live branch compare links
and shell PR references; a recorded verified tip is evidence for that snapshot.
If a commit manifest is required, generate it or update it in the same push and
revalidate it. The integration body summarizes existing contracts rather than
replacing their scope, acceptance criteria, or dependencies.

## SI-09: Resolve ambiguity before expanding authority

Check the user's existing authorization first. A clear approved plan needs no
repeat confirmation. Otherwise, "continue" or "next steps" does not authorize
deployment, final-target merge, shared rebase, or closing shells.

State the intended boundary in one line, for example: "Merge ready shells into
integration only; leave the final target and shared environment unchanged; keep
unmerged shells open." If the integration destination or merge authority itself
is unclear, ask and wait before dependent mutations. Read-only inspection and
already authorized work may continue. Silence is not approval.

## SI-10: Verify each boundary against current GitHub state

Before every integration merge, verify the shell's current head/base, satisfied
dependencies, diff scope, placeholder removal, and applicable checks on that
head. Inspect automatic deployment triggers before pushing or merging; stop if
the action would change a shared environment without explicit approval.

After merging, verify the remote integration tip, expected shell inclusion,
GitHub PR state, synchronized child bases/metadata, and required integration
checks. Before final-target merge, review the complete compare diff, confirm all
intended shells and QA checks, and confirm the applicable sign-off. Report
blockers separately from completed integration; never infer deployment from a
successful merge.
