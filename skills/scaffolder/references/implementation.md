# Implementation and recipe composition

## Contents

- [Source of truth](#source-of-truth)
- [Follow one request](#follow-one-request)
- [Compose a starter and recipe](#compose-a-starter-and-recipe)
- [Choose the GitHub client](#choose-the-github-client)
- [Understand publication limits](#understand-publication-limits)
- [Find code and tests](#find-code-and-tests)

## Source of truth

Use this reference for the implementation in
[PR #76](https://github.com/judigot/scaffolder/pull/76), verified against
[commit 285be7b](https://github.com/judigot/scaffolder/tree/285be7bdc7932ca267ac3555dd29ada7c022f88b).
Read the target deployment's source when behavior differs. Do not assume a PR
has been merged or deployed simply because this skill documents it.

## Follow one request

1. Authenticate the Scaffolder bearer key (or the existing Auth0 path). Read the
   optional PAT from `X-GitHub-Token`, outside the JSON body.
2. Validate the strict request schema, project/target URLs and nonempty schema.
3. Load the project recipe and its supporting files. For a remote project URL,
   check the repository is public, resolve its ref to a full commit, and fetch
   the archive at that commit. A legacy `project` uses bundled host files.
4. Resolve the base: request `template_repo` wins over recipe `$BASE`, `$SOURCE`
   or string `source`. A local `/Core/...` base uses the recipe's files repo.
5. For a remote base, resolve its actual default branch or supplied ref once,
   then fetch the archive by commit. Scope to a requested subdirectory. Never
   retry a missing folder by returning the root instead.
6. Compose base files, explicit replacements, Core imports and generated files.
   Finish schema/filter, conflict, placeholder and `USE_USER_ENV` checks.
7. Only after a successful build, create the destination if `create_repo: true`.
8. Use the selected destination credential to commit on a scaffolder branch and
   create/update the PR. Return the destination commit and source snapshot SHAs.

Source pinning is internal. Users normally provide repository/project URLs.
One generation uses one resolved snapshot for each remote source. A later
generation may resolve a newer commit. Default PR text includes source SHAs;
the response also exposes them. Custom `prBody` replaces the default text, so
use the response when retaining provenance.

Download tarballs; do not execute starter installation/build scripts. Enforce
30-second fetch timeouts, 25 MiB compressed, 100 MiB extracted, and 20,000 files.
Reject unsafe paths. Preserve text/binary contents; skip symlinks and submodules.
Archive extraction must also work in the browser project builder without a
Node `Buffer` global.

## Compose a starter and recipe

Edit the actual `Projects/<name>/structure.yaml` in the selected files repo when
changing recipe composition. There is no new API request field named `replace`.

```yaml
$BASE: https://github.com/judigot/template-monorepo
replace:
  - apps/api/**
$USE_CORE:
  - /Core/nestjs-api
```

This example uses the public starter, removes its API subtree from the generated
base, then adds the in-house Nest Core. It does not modify the source repository.
The recipe still needs its normal generation instructions and schema filters.

For an in-house base, use `$BASE: /Core/template-monorepo`. Existing `$USE_CORE`
recipes remain valid without `$BASE`. The fallback follows that recipe's imports;
it is not an unconditional promise that every recipe includes a monorepo.

Apply layers in this order (later files win at matching paths):

1. Selected remote starter or local base.
2. Recipe `replace` globs applied to that base.
3. Remaining `$USE_CORE` imports in order.
4. The project's local `core/` files.
5. Recipe-generated output.

A remote starter skips the redundant `/Core/template-monorepo` base import.
Keep the other imports; do not remove every in-house Core just because a starter
URL was supplied. Without a remote base, preserve the existing Core import order.

For Hono-to-Nest transitions, replace the entire `apps/api/**` subtree. Replacing
only `apps/api/package.json` leaves source imports and fails with
`TEMPLATE_API_CONFLICT`. After a full replacement, remove Hono dependencies from
the root and API package manifests; preserve unrelated apps' dependencies.

Treat `replace` as deletion from the in-memory generated base. It is not a
repository-wide delete command. Ordinary overlays cannot express arbitrary
deletion of existing destination files. This feature does not automatically
convert every starter's framework, routing, environment setup or deployment.

## Choose the GitHub client

| Credential | Used for | Stored by this feature? |
| --- | --- | --- |
| Scaffolder agent key | Authentication to Scaffolder | Host/runtime secret configuration |
| Request `X-GitHub-Token` | All destination operations for that request | No |
| App installation token | Destination publication and organization creation when no request PAT is supplied | Existing App service manages it |
| Existing Auth0-stored GitHub token | Legacy personal creation for an Auth0 caller | Existing Auth0 integration, not a new PAT store |
| Optional host `SCAFFOLDER_SOURCE_GITHUB_TOKEN` | Public-source REST reads only | Server configuration |

With a request PAT, call `users.getAuthenticated` before personal creation and
require the authenticated login to match the destination owner. Use
`repos.createForAuthenticatedUser` for personal owners and `repos.createInOrg`
for organizations. Keep commits and PRs on the PAT client as well.

Without that PAT, preserve the existing App/Auth0 flow. An agent-key caller has
no stored Auth0 identity, so an App alone cannot create a personal repository.
App Administration read/write does not change this endpoint restriction. It
can still publish to existing personal repositories where it is installed.

Create repositories private with `auto_init: true`. Reject collisions. Once
creation succeeds, retain `repoCreated`/`repoUrl` in later error recovery. Never
delete a created repository automatically. Retry publication without creation.

Disable credential-bearing SDK logs and redact the request PAT in error messages
and details. Do not serialize the PAT with publish parameters or generated files.
Do not send a destination PAT to public source fetches.

The optional server source token goes only to `https://api.github.com`, with
redirects disabled. Check `private: false` even for explicit source refs. Fetch
archives without that credential. Keep the server helper out of browser imports.
Without a source credential, GitHub's unauthenticated 60 requests/IP/hour limit
applies: two REST reads per remote source, about 15 two-source generations/hour
per shared host IP. Explain rate-limit recovery; do not rotate destination PATs
to evade source limits.

## Understand publication limits

Keep default-branch generation protected. A newly created repo is initialized
before publication; the publisher also has an empty-repository initialization
path. Do not promise that publication performs no initialization writes at all.

For PR updates, use the current branch head as commit parent and fast-forward
only. Never force-push. An identical generated tree returns the current commit.

The current publisher constructs the generated tree from the destination's
default-branch tree, even when the commit parent is the existing PR head. It
does not preserve all branch-only manual changes. Inspect the branch diff before
regenerating a manually edited PR. Do not describe this as an arbitrary patch or
automatic migration engine. Prefer greenfield generation or dedicated generated
PRs; perform ordinary feature changes directly in the app repository.

## Find code and tests

Interpret the paths below relative to `judigot/scaffolder`, not `judigot/ai`.

| Files | Responsibility |
| --- | --- |
| `src/app/routes/agentScaffold.ts`, `src/schemas/agentScaffold.ts` | Bearer/PAT headers, strict JSON contract, response status and redaction |
| `src/app/services/agentScaffoldService.ts` | Recipe loading, build gates, optional creation, publication, source provenance and recovery |
| `src/utils/parseAgentScaffoldUrls.ts`, `src/utils/parseTemplateRepo.ts` | Project/destination/PR URLs, starter refs and subdirectory selection |
| `src/utils/resolveGitHubSnapshot.ts`, `src/app/services/publicSourceFetch.ts` | Public visibility, default branch, full commit resolution and optional server read credential |
| `src/utils/fetchPinnedRepoTarball.ts`, `src/utils/extractTarGz.ts`, `src/utils/concatBytes.ts` | Bounded archive download and portable extraction |
| `src/utils/project-builder/utils/resolveTemplateBase.ts`, `loadCoreFiles.ts`, `recipeDirectives.ts` in the same directory | Base precedence, recipe directives, replacement and Core layering |
| `src/utils/project-builder/buildProjectFiles.ts` | Generation, composition and build messages |
| `src/app/services/agentCreateRepoService.ts`, `agentGitHubToken.ts` in the same directory | PAT/App creation selection, owner checks, collision/recovery, credential handling |
| `src/app/services/githubDraftPullRequestService.ts` | Git blobs/trees/commits, branch reuse and PR publication |

Use the existing tests rather than adding privileged CI jobs that create real
repositories or download a moving live template. Start with these focused files
when changing the host:

```sh
bun test src/tests/app/services/agentScaffoldPublicSources.test.ts \
  src/tests/app/services/agentCreateRepoService.test.ts \
  src/tests/app/services/agentScaffoldService.test.ts \
  src/tests/app/routes/agentScaffoldToken.test.ts \
  src/tests/utils/resolveGitHubSnapshot.test.ts \
  src/tests/utils/extractTarGz.test.ts \
  src/tests/utils/project-builder/utils/resolveTemplateBase.test.ts
```

The public-source fixture test exercises URL resolution, an in-repo tar fixture,
the real builder, Hono replacement, and mocked GitHub PAT creation/publication
for personal and organization owners. Keep no-template/Core golden generation
offline. Existing CI also covers Bun, Vitest, lint, golden frameworks, Playwright
and API/preview smoke checks.
