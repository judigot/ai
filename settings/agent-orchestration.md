# Agent orchestration policy

This policy keeps one main orchestrator while routing bounded planning and
implementation work through eligible providers. It is provider-neutral: the
orchestrator owns requirements, architecture, integration, verification, and
the final report regardless of the worker route.

## Main orchestrator

- Interface: Codex CLI.
- Default model when no main-chat model is selected: `gpt-6-astra`.
- Default reasoning effort: `medium`.
- The user may select another available model or reasoning effort for the main
  chat at any time. That explicit selection becomes the orchestrator for the
  session and does not change worker-route priorities.
- OpenCode may be the main interface only when the user explicitly selects it.
  If its configured model cannot provide the orchestrator role, ask the user to
  select a supported alternative.

The selected main-chat model keeps the main conversation and reviews every
worker plan, diff, and verification result. Changing a worker never changes
the main conversation.

## Verified mappings

| Role | Route | Executable model ID | Reasoning | Status |
| --- | --- | --- | --- | --- |
| Orchestrator | Codex CLI | `gpt-6-astra` | medium | active |
| Planner fallback | Codex CLI | `gpt-6-astra` | medium | active |
| Implementation worker 1 | Codex CLI | `gpt-5.6-luna` | low | active |
| Implementation worker 2 | Codex CLI | `gpt-5.6-terra` | low | active |

These IDs were verified in the local Codex model cache. Codex CLI supports
`--model`, `-c model=...`, `model_reasoning_effort`, `exec` for non-interactive
work, and managed worktrees.

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

### Planning

1. Use Cursor CLI with its verified included-subscription planner when that
   route is available and has a read-only execution mode.
2. Otherwise use Codex CLI with `gpt-6-astra` at medium reasoning.
3. Otherwise use only an approved free OpenCode planning model.

Planning workers do not modify source files. If a tool cannot enforce
read-only work, use a disposable worktree and inspect it for changes.

### Implementation

1. Use the first eligible Cursor model in its verified route.
2. If Cursor is unavailable or its included pool is exhausted, use Codex CLI:
   `gpt-5.6-luna` at low reasoning, then `gpt-5.6-terra` at low reasoning.
3. If Codex is unavailable, use only the approved free OpenCode route.

Retry a model-specific transient failure at most twice before trying the next
model in the same route. A shared-pool exhaustion skips every model in that
pool. Authentication failures require reauthentication and a different eligible
route; never move credentials between tools. Test failures, ambiguity, and poor
worker output are quality failures, not quota failures.

Recheck a higher-priority route only at a later task boundary after access is
known to be restored. Let healthy workers finish.

## Worker contract

Use workers only for bounded tasks. Every planning report includes the
objective, assumptions, affected files and dependencies, steps, bounded tasks
with file ownership, dependency order, acceptance criteria, required checks,
risks, and escalation points.

Every implementation brief includes the objective, owned files, constraints,
non-goals, acceptance criteria, required checks, and the expected concise
report. Keep trivial work with the orchestrator. Parallelize only independent
work in isolated worktrees with non-overlapping ownership.

The orchestrator inspects partial changes before replacement, preserves valid
work, and reviews the final diff and verification evidence.

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
