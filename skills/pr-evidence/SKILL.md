---
name: pr-evidence
description: Capture and publish unattended screenshots or demo video as review evidence when a user asks for PR or ticket UI evidence, a demo video, a screenshot for GitHub or Linear, proof that a UI fix works, or Playwright recording for review. Prefer judigot/agent-workspace as the execution/orchestration environment and judigot/app-screencast as the reusable recording toolkit.
---

# PR and ticket UI evidence

Use this skill for review evidence and recording-capability demos, not product
functionality.

The default architecture is:

```text
judigot/agent-workspace
  = recording execution/orchestration
  -> isolated cloud runner
  -> checkout target repo @ exact SHA
  -> checkout/use pinned judigot/app-screencast
  -> start target app or public-site fixture
  -> execute scenario
  -> retain/publish evidence

judigot/app-screencast
  = reusable recording toolkit
  -> Playwright capture helpers
  -> pointer / labels / zoom
  -> composition / ffmpeg export
  -> media validation
  -> narration / manifests / technical evidence as those capabilities land

target repository
  = application under test
  -> product source
  -> optional thin scenario or host adapter
  -> product assertions/selectors when needed
```

Do not put the generic recording runner into every target repository. The target
is what gets recorded; `agent-workspace` is where recording work is scheduled
and executed.

## Ownership rules

### agent-workspace owns

- cloud/GitHub Actions execution;
- isolated workspaces and per-run identities;
- checking out the target repository at the exact PR SHA;
- checking out or installing a pinned `app-screencast` revision;
- target bootstrap and readiness orchestration;
- recording-job scheduling and concurrency;
- artifact retention/publication;
- association of evidence with repository, PR, and exact SHA;
- eventual Evidence Gate/readiness integration.

### app-screencast owns

- generic Playwright recording helpers;
- fake pointer, labels, zoom, and presentation behavior;
- WebM/MP4 capture and ffmpeg composition;
- media validation;
- reusable public-site capability fixtures;
- narration/audio composition when implemented;
- evidence manifests and sanitized technical-evidence primitives when implemented.

### target repository owns

Only target-specific facts that cannot safely be inferred, such as:

- startup command and base URL;
- readiness probe;
- deterministic seed/reset;
- actors/authentication entry points;
- scenario steps;
- selectors and expected product assertions;
- cleanup.

A target repository may eventually expose these through a small convention such
as:

```text
.agent/evidence/
  booking-confirmation.ts
  host-adapter.ts
```

The exact target-adapter format is not yet canonical. Do not invent a large
framework in the product repository to compensate.

## Principles

- Keep generic screencast orchestration outside the product repository.
- Do not add demo-video packages such as `human-cursor`, `testreel`,
  `demohunter`, or `playwright-recast` to the target app's
  `package.json`.
- Do not copy `app-screencast` helpers into the target repository.
- If the product already uses Playwright, reuse its application-level selectors,
  fixtures, or assertions when useful, but keep recording/composition machinery
  in the toolkit.
- Pin the `app-screencast` revision used by unattended evidence runs. Evidence
  must not silently float to an unreviewed toolkit revision.
- Keep PNG, WebM, MP4, trace, and temporary output outside the target Git
  worktree or in ignored run directories. Never commit evidence binaries unless
  the user explicitly requests it.
- Inspect the final artifact. A green Playwright assertion is not visual
  confirmation.
- State which acceptance criteria each artifact proves.
- Keep secrets, authentication headers, cookies, tokens, personal information,
  and unrelated notifications out of published evidence.

## Implementation video evidence invariants

These are non-negotiable for normal product PR evidence. The authoritative
contract is
`judigot/agent-workspace/docs/pr-implementation-video-evidence-invariants.md`.

### VE-001 — Implement before recording

The requested product behavior must exist on the PR branch before the evidence
recording begins.

Correct:

```text
implement
  -> test
  -> push
  -> record
  -> attach video to the same PR
```

Never record a mock/surrogate first and present it as proof of later
implementation.

### VE-002 — Record the exact implementation head

Freeze the current PR head SHA before evidence generation. Record that exact
SHA. Re-check the PR head before publication and readiness.

If the head moved, the old recording is stale. Re-record the new head.

### VE-003 — Show the acceptance criterion directly

The scenario must demonstrate the behavior the PR implements.

Example:

```text
PR: add a "Say Hello" button that alerts "Hello World"

evidence:
  open implemented target app
  -> show Say Hello button
  -> click it
  -> visibly show alert containing Hello World
  -> attach video to that implementation PR
```

Prefer the shortest scenario that makes the acceptance criterion obvious.

### VE-004 — Keep machine verification

Video supplements tests/assertions. It does not replace them when the behavior
can be verified automatically.

For the Hello World example, prefer both:

- an automated assertion for the alert text;
- a video showing the reviewer the same behavior.

### VE-005 — Keep recording infrastructure outside the product repo

`agent-workspace` owns execution/orchestration/publication.
`app-screencast` owns reusable capture/composition/media tooling.
The target repository owns the implementation and only thin target-specific
scenario/adapter facts when necessary.

Do not add generic recording workflows, ffmpeg composition code, copied
screencast helpers, or demo-only dependencies to the implementation PR.

### VE-006 — Record the target application

Product implementation evidence must exercise the target application at the
exact PR head.

Public-site recordings are capability demos only. They may test the recording
pipeline, but they are never proof that the target implementation works.

### VE-007 — Requested publication surface is part of success

If the user asks for the video on the PR, the task is not complete when an MP4
exists or when an Actions artifact uploads successfully.

The playable video must appear in the implementation PR conversation.

### VE-008 — Upload and comment may use separate trusted credentials

GitHub attachment upload and PR comment creation can have different permission
requirements.

A valid trusted publication flow may therefore be:

```text
trusted uploader
  -> upload MP4 to GitHub user attachments
  -> receive github.com/user-attachments/assets/<id>

trusted commenter
  -> post that GitHub-hosted URL to the implementation PR
```

Do not expose credentials. Do not use a temporary signed download URL as the
durable PR evidence URL.

### VE-009 — Verify publication after writing

After posting evidence:

- fetch the PR conversation;
- confirm the expected comment exists;
- confirm it references the intended GitHub-hosted video;
- when browser access is available, confirm it renders/plays in the PR UI.

Do not declare evidence complete from the upload command alone.

### VE-010 — Clean temporary orchestration state

After one-shot evidence/publication work:

- restore temporary agent task hooks such as `.agent/run.sh` to their canonical
  no-op state;
- remove temporary signed URLs/scripts/files;
- do not leave publication machinery queued.

Reusable behavior belongs in the canonical runner.

### VE-011 — Evidence failure blocks evidence-required readiness, not implementation truth

A recording/publication failure does not mean the implementation itself is
wrong if its machine verification is green. It does mean an evidence-required
PR is not ready.

Retry evidence against the same SHA, or against the new SHA if the PR moved.

### VE-012 — Zero-diff evidence PRs are demo fixtures only

A PR containing one empty commit, zero changed files, and only a video comment
is valid for testing the evidence-publication pipeline.

It is **not** the normal implementation workflow.

The canonical product workflow is always:

```text
implementation PR with real code changes
  -> implementation verified
  -> exact implementation head recorded
  -> video attached to that same PR
```

## Capability demo versus PR evidence

A public-site fixture is valid when the goal is to showcase or test
`app-screencast` itself.

Example:

```text
agent-workspace
  -> app-screencast public-site scenario
  -> Playwright docs + Wikipedia
  -> side-by-side / multi-window MP4
```

That proves recording capabilities such as pointer movement, typing, labels,
zoom, scrolling, multiple contexts, composition, and media export.

It does **not** prove anything about a selected target repository. Do not attach
a public-site capability demo to a Scaffolder PR and describe it as evidence
that Scaffolder behavior passed.

Actual PR evidence must execute the target app at the exact target SHA.

## Execution flow

For normal product PR evidence, implementation is already complete enough to be
verified before this evidence flow starts.

For target evidence, prefer this sequence:

1. Confirm the requested implementation is present and its prerequisite machine
   verification has passed.
2. Resolve the target repository, implementation PR number, and exact current
   head SHA.
3. Start an isolated `agent-workspace` evidence runner.
4. Checkout the target repository at that exact SHA.
5. Checkout or install a pinned `judigot/app-screencast` revision in a
   separate tools directory.
6. Bootstrap only the target dependencies/services required by the scenario.
7. Load the target-specific scenario/adapter, if one is required.
8. Execute the shortest scenario that visibly proves the relevant acceptance
   criteria.
9. Run product assertions as well as media validation.
10. Inspect representative screenshots/frames and the final video.
11. Re-check that the implementation PR head is still the recorded SHA.
12. Upload the video to durable GitHub-hosted media.
13. Attach/post the playable video to the **same implementation PR** with
    acceptance-criterion and source-SHA context.
14. Fetch the PR conversation and verify that publication succeeded.
15. Only then report evidence completion/readiness for that exact SHA.

A moved target head invalidates the old evidence.

## Scenario selection

Choose the shortest journey that proves the acceptance criteria.

Prefer:

- deterministic test data;
- isolated user/session state;
- explicit product assertions;
- condition-based waits;
- a focused 30–90 second review video when possible.

For multiple actors, use separate browser contexts. If simultaneous visibility
materially helps the reviewer understand the behavior, use side-by-side
composition.

For a visual-only change, a PNG may be sufficient. For a multi-step workflow,
use MP4. Use Playwright traces for debugging rather than as executive review
evidence.

## Target-app Playwright

Do not globally install a second Playwright copy just to test an application.

When the scenario needs the target app's existing Playwright fixtures or
selectors, use its pinned project dependencies for the application-level test
contract. The recording toolkit may have its own pinned Playwright dependency
in its separate tools checkout.

Keep these roles distinct:

```text
target Playwright
  = app fixtures / selectors / assertions, when needed

app-screencast Playwright
  = recording presentation and capture tooling
```

Do not mutate the target lockfile merely to enable evidence recording.

## Media output

Use the toolkit's export and validation path rather than duplicating ffmpeg
commands in every product repository.

At minimum, validate that:

- the expected video exists and is non-empty;
- duration covers the final meaningful state;
- resolution/container/codec match the declared profile;
- the final frames were not truncated;
- audio exists when the evidence profile requires it.

When narration/audio support is not implemented for the selected toolkit
revision, say so explicitly rather than presenting a silent capability demo as
the canonical narrated showcase.

## Publication

Until the trusted Evidence Gate and manifest path is implemented end-to-end,
GitHub Actions artifacts and PR attachments/comments are acceptable review
surfaces.

When attaching a video directly to a PR, keep the attachment operation in the
trusted wrapper/orchestration layer rather than embedding GitHub publication
logic in the product application.

For example:

```sh
gh pr comment "$PR_NUMBER" \
  --body "**Evidence (video)** — exact head: $TARGET_SHA" \
  --attach "$mp4"
```

Open the resulting PR comment and confirm the attachment rendered. If the PR
head has changed, do not call the old recording current evidence.

When Evidence Gate support exists, the manifest/check result becomes the trusted
readiness signal; the human-facing video remains supporting evidence.

## Before declaring evidence done

- [ ] Target repository and PR are correct.
- [ ] Evidence was generated for the exact target head SHA.
- [ ] Generic recording orchestration ran outside the target repository.
- [ ] `app-screencast` revision was pinned.
- [ ] Product assertions passed, or failures are disclosed.
- [ ] Media validation passed.
- [ ] Screenshots/frames and the final video were actually inspected.
- [ ] Acceptance criteria are mapped to evidence.
- [ ] Secrets/private data are absent from published artifacts.
- [ ] The target PR head still matches the recorded SHA.
- [ ] No demo-only dependency, generic recording workflow, or evidence binary
      was added to the product repository unnecessarily.

## Anti-patterns

- Putting the generic screencast GitHub Actions workflow in every target repo.
- Treating `scaffolder` or another product repository as the recording
  orchestrator.
- Copying `app-screencast` helpers into the product.
- Adding demo-only video packages to the product app.
- Mutating the product lockfile only for evidence recording.
- Calling a public-site capability demo proof of target-app behavior.
- Claiming visual verification without opening the artifact.
- Reusing evidence after the target PR head moves.
- Letting a video replace stronger machine assertions for nonvisual behavior.

## Canonical reference

The execution/readiness contract lives in:

`judigot/agent-workspace/docs/evidence-backed-readiness.md`

That document is authoritative for orchestration and exact-SHA readiness.
This skill is the agent-facing operating guidance for following that contract.
