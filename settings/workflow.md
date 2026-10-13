# Session protocol

This repository is the overlay for every agentic chat: coding rules, routing, and delivery discipline.

Provider routing, model mappings, worker contracts, and durable handoffs are
defined in `settings/agent-orchestration.md`. That policy takes precedence over
generic agent or model defaults in this overlay.

Other people's skills live on the web. **Reference them. Do not download them.** See `settings/references.md`.

Implement in the user's project. Only edit `judigot/ai` when the user is changing this workflow.

## 1. Setup entrypoint

Before writing code:

1. Follow this overlay's `AGENTS.md` loading policy: try remote instructions every session, then use `~/ai` only if a required remote file is inaccessible. Clone there if absent; verify and preserve an existing checkout. Read all required files from the selected source and report local version/freshness when falling back. When maintaining `judigot/ai`, use the workspace files. Bootstrap through agent-level instructions or `prompts/prompt-init-chat.md`; do not install a loader or overlay files in the app.
2. Confirm the workspace is the **app repo**, unless the user is maintaining this overlay. A fallback clone is an instruction source, not the app workspace.
3. Use the official skill for that layer in `settings/stack.md`. Do not invent a parallel stack.
4. Search this project before inventing a new solution.
5. If the goal, UX, or success criteria are ambiguous, **ask clarifying questions**. For a full grilling session, fetch the grill URL in `settings/references.md`. Do not implement yet.
6. If the destination is nameable but the route is not, and the work will not fit one session, fetch and follow **wayfinder** from `settings/references.md`. Plan and decide. Do not build.
7. Never `git clone` / `npx skills add` third-party skill repos to satisfy a route.

When the workspace is `judigot/template-monorepo`, also follow that repo's `docs/ecosystem.md`.

Product repos stay standalone: do not include `settings/ecosystem.md` from a
product's `AGENTS.md`. That file is for template and overlay maintenance.

Git is the only source of truth for worktree state; do not create sprint `.state`
files. An app-level `CONTEXT.md` from a grilling session records domain language,
not worktree or sprint metadata.

## 2. Route

Apply explicit instructions, inspected PR contracts, and exact repository rules
first. Only unresolved semantic workflow choices may consult Jev through Agent
Workspace's existing adapter. Fixed/trivial tasks require no model call. Follow
JR-001…JR-005 in `docs/typesafe-jev.md`; a `needs_review` outcome returns to the
existing orchestrator without weakening verification or changing worker authority.


| Situation | Do this |
| --- | --- |
| Ambiguous product or behavior | Clarify / fetch grill. Do not code. |
| Original product ideas / founder direction | `agents/founder-ideator.md`; keep the pitch short, then hand off. |
| Pitch/idea → FRD, PR shells, dependency graph, TDD contract | `agents/spec-compiler.md`; use Terra tier. |
| Sleep / overnight / unattended implementation | `skills/sleep-and-forget/SKILL.md` + `agents/overnight-orchestrator.md`; use PR shells and dependency-aware scheduling. |
| Effort bigger than one session, route unclear | Fetch wayfinder. Plan and decide, do not build. |
| Locked spec or ticket | Skip ideation/spec compilation; TDD, then implement with the implementation worker route. |
| React UI, design-system components, or HTML-to-React conversion | Read `settings/frontend.md` and `skills/frontend-design/SKILL.md`; apply the React/Next.js routes below as appropriate. |
| Static HTML previews inside an existing mock gallery | `agents/ui-mock-iframe.md` |
| PR/ticket needs UI evidence (screenshots or demo video) | Read and follow `skills/pr-evidence/SKILL.md`. |
| Existing Java/Spring backend | Read `settings/backend-java.md`; for JUnit additions or maintenance, use `skills/junit-test-implementation/SKILL.md`. |
| Hard bug with no reliable repro | Fetch diagnosing-bugs, else debugger agent |
| React | Fetch vercel-react-best-practices and vercel-composition-patterns |
| Next.js | Fetch https://www.skills.sh/vercel/next.js |
| Vercel deploy | Fetch deploy-to-vercel |
| Turborepo | Fetch https://www.skills.sh/vercel/turborepo |
| Vite | https://vite.dev/guide/ (no official skills.sh pack) |
| TypeSafe / Jev requested, or semantic routing, ranking, extraction, verification, or development-workflow classification needs typed judgments | Fetch the official TypeSafe skill from `settings/references.md`; follow `docs/typesafe-jev.md`. For workflow distillation/recipe selection, Agent Workspace is authoritative and Jev remains observation-only. |
| Hono / Zod / Playwright / lint | Overlay rules + `lint-master` / `tdd-ci`. No official maker pack. |
| Fast client MVP / generate app from schema / Scaffolder | `skills/scaffolder/SKILL.md`. Draft PR on the target repo. Do not write `main`. |
| "Is there a skill for X?" | Official makers first (https://skills.sh/official), then the catalog |
| Lint-only or formatter fights | `lint-master` |
| Visible EC2 agent desktop / live UI testing / cloud workstation recordings | `skills/cloud-dev-desktop/SKILL.md` |
| Unsure which Matt Pocock flow | Fetch ask-matt |

For exact ChatGPT GitHub connector tool names, required arguments, branch/PR/comment examples, and known provisioning gaps, follow [the low-tier ChatGPT tool cookbook](../docs/chatgpt-github-tools.md). Do not claim a direct Agent Workspace provisioning tool exists unless it is actually connected and callable.

## GitHub template repository creation

When creating a new application from an existing GitHub template repository, prefer GitHub's native `POST /repos/{template_owner}/{template_repo}/generate` operation over cloning and pushing. Use a descriptive repository name based on the user's request. Confirm target ownership/visibility, check for naming collisions, and never overwrite an existing repository. Template generation creates fresh history rather than copying the template's commits. Preserve generated `main` as the unchanged baseline and implement new features on a PR branch.

In ChatGPT-first workflows, the existing GitHub connector should use `judigot/agent-workspace`'s trusted **owner-authored declarative provisioning PR** workflow when direct template generation is unavailable. The agent creates `provision/repository-NAME`, adds exactly `.agent/repository-requests/create.json`, and opens a PR against `main`. GitHub Actions provisions the private repository immediately from trusted default-branch code. **Never merge the request PR, post an execution comment, or push executable scripts to `main` to create a repository.** Only proceed after explicit current-chat owner authorization. Read `judigot/agent-workspace/docs/owner-pr-repository-provisioning.md` for exact tool calls; the workflow must already be installed on `main`. A separate ChatGPT Action is optional, not a prerequisite.

Before creating a Neon database, Vercel project, or implementation branch, verify provisioning succeeded. Fetch the provisioning PR head SHA with `mcp__GitHub__get_pr_info`, then read the exact `Repository Provisioning` context through `mcp__GitHub__get_commit_combined_status`. Require `success` and independently confirm the private destination repository and template baseline. `pending` or missing status means **not verified**; `failure` requires diagnosing the status/workflow link. For GitHub HTTP 403, identify the `AGENT_WORKSPACE_GH_TOKEN` creation-permission blocker; do not invent a repository, blindly reopen PRs, or create downstream cloud resources. A single matching file SHA is only partial evidence. Do not declare application features, databases, or deployment complete until independently verified. See `judigot/agent-workspace/docs/github-template-provisioning.md` for the operational procedure.

## Tool capability and execution evidence

- Inspect current tool declarations and verify callability before asserting an operation is unavailable. Distinguish missing operation, safety-check rejection, authorization failure, validation failure, and transient runtime failure. A failed call does not prove a permanent connector limitation.
- Before retrying any mutation, inspect its possible side effects: branch, commit, PR, comment, workflow run, external resource, or deployment. Do not blindly retry privileged dispatch or assume creating the same resource twice is safe.
- Check for an existing owner authorization for the same task and exact reviewed SHA before posting another dispatch command. Explicit authorization in ChatGPT can authorize the agent's tool action, but the executor still needs an independently authenticated trusted trigger.
- Treat these as distinct milestones: request submitted, owner identity accepted, workflow started, workflow succeeded, and target state verified. Report the furthest observed milestone, not the intended one.
- Prefer an existing approved native tool or trusted workflow over introducing new dispatchers or architectural components. Keep the trust boundary intact and document a durable change only when a repeated failure or reusable invariant justifies it.

## Privileged PR execution

Privileged automation that uses repository secrets, GitHub PATs, cloud credentials, or other elevated access must not automatically execute unreviewed PR code. A private repository or a PR authored by the owner or an AI agent is not, by itself, authorization.

For `judigot/agent-workspace`, preserve the automatic `Agent Exec` execution boundary on trusted `main`. PR-based privileged runs require an explicit owner command `/agent exec <40-character lowercase PR head SHA>` and the trusted default-branch `Owner-approved PR Agent Exec` workflow. Validate commenter identity, same-repository open PR, and exact current head without privileged credentials; revalidate before the privileged job, then checkout and verify that SHA before exposing task secrets. A changed head needs fresh authorization. Review executable code and dependencies before approving. Do not use `pull_request_target` to execute untrusted PR code with secrets.

See `judigot/agent-workspace/docs/owner-approved-pr-exec.md` for the executable contract. Do not confuse PR validation with owner authorization.

## 3. Test-driven delivery

Apply delivery checks to the task: read-only work needs no tests, commits, CI, or
PR. For documentation-only edits, review text, links, and the diff. Commit, push,
and create PRs only when authorized and permitted by the environment. If a
required check cannot run, report the blocker and verified results separately;
do not claim full validation. These qualifications also apply to delivery skills.

- Red → green → refactor, one vertical slice at a time.
- Overlay rules: `skills/tdd-ci/SKILL.md`. For Matt Pocock's loop, fetch the tdd URL in `settings/references.md` — do not install it.
- Write the failing test first. Commit it. Then write the minimum code that makes it pass.
- **CI is the success signal.** Local tests are a preview. Do not treat the task as done while CI is red or missing for a change that should be covered.
- Users will often only look at CI. Make that status trustworthy.
- Optimize PR CI for iteration speed, but keep production deployment fail-closed.
  Do not let a production deployment start while required business-critical
  checks are failing, cancelled, missing, or still running. Prefer parallel
  validation followed by an explicit dependency-gated deploy.

## 4. Mini commits, push early

- Commit each meaningful slice (failing test, implementation, refactor, lint). Never batch a whole feature into one commit.
- Push after every commit so the PR and remote have the work before the session hits a token limit.
- Conventional Commits, short subject. Stage specific files, not `git add .`, unless the slice is the whole intended change.

## 5. Clarifying questions

Ask when the answer changes architecture, UX, data, or scope.

Do not ask about defaults already in `settings/rules.md` (strict TypeScript, Bun, ESM, interface prefix `I`, no `console.log`).

If a parent agent already locked the spec (task-master spawned with a goal), execute. Do not re-grill.

## 6. Pull requests

Before creating or updating a PR, read `settings/repository-pr-contracts.md` and inspect the target repository's current PR template/CI contract. Repository-local machine-readable metadata must stay synchronized with this overlay's dependency and ownership plan.

Use `settings/pr-body.md` for ordinary PRs whose implementation is being
delivered in the current workflow.

Use `settings/pr-shell.md` when creating a draft PR before implementation,
handing implementation to another agent/model, scheduling unattended work, or
coordinating dependency-aware parallel/sequential PR execution. A PR shell is
the eventual delivery PR opened early, not a precursor PR. Continue
implementation on that PR's existing head branch and keep the same PR draft
until its ready-state rules pass. One independently deliverable unit normally
has one delivery branch and one PR; parallel execution isolates those existing
branches with runners/checkouts/worktrees rather than creating duplicate PRs.
Do not infer a `pr-shell/*` branch prefix from the term "PR shell"; follow the
target repository's branch-naming convention. Let the orchestrator derive
execution order from dependency metadata. For `judigot/scaffolder`, apply the
Scaffolder adapter in `settings/repository-pr-contracts.md`; `PR CI / PR Gate`
is the stable PR readiness signal.

Every PR must include a **manual testing checklist** a non-technical person can
follow: numbered steps, what to click, what they should see, and how to know it
failed. Infrastructure-only work may use a checks-based verification flow when
there is no meaningful user-facing manual path.

### Sprint integration and shared environments

For a sprint integration branch before the final target branch, read and follow
[settings/sprint-integration.md](sprint-integration.md). The orchestrator merges
existing shells in dependency order and maintains their bases and metadata;
the integration PR is the single path to the final target.

Dispatch a deployment or otherwise change a shared environment only when the
user explicitly authorizes that action. Integration or QA authorization does
not imply deployment authorization. Phrases such as "continue next steps" do
not expand the approved scope to final-target merges, deployments, shared
history rewrites, or PR retirement. Check automatic deployment triggers before
an authorized push or merge; if it would change a shared environment outside
the user's approval, stop before that action and explain the side effect.

## 7. Self-audit

Before stopping, follow `skills/self-audit/SKILL.md`. Fix applicable failures and report checks or delivery steps that remain blocked. Do not claim tests passed or work was published when it was not.
