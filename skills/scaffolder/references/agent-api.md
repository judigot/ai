# Agent API: requests and recovery

## Contents

- [Fields](#fields)
- [Prepare one input file](#prepare-one-input-file)
- [Choose one curl request](#choose-one-curl-request)
- [Read the response](#read-the-response)
- [Recover from errors](#recover-from-errors)

## Fields

Send JSON to `POST /api/agent-scaffold`. Authenticate with the Scaffolder bearer
key. Add `X-GitHub-Token` only when choosing the PAT destination path.

| Field | Required/default | Meaning |
| --- | --- | --- |
| `schemaInfo` | Required, nonempty | Compact schema string or valid table array; see the main skill |
| `project_url` | Required unless `project` is supplied | Public GitHub URL to `Projects/<name>` or its `structure.yaml` |
| `project` | Optional alternative | Bundled host project folder name; `project_url` wins if both are present |
| `target_repo` | Required | Destination repository root URL or `owner/repo` |
| `template_repo` | Optional | Public starter URL; overrides recipe `$BASE` / `$SOURCE` / string `source` |
| `create_repo` | `false` | Create a private, initialized destination before publishing |
| `branch` | Generated when no PR selector is supplied | Reuse a named branch; `scaffolder/` is added if absent |
| `prNumber` | Optional positive integer | Update that open PR on `target_repo` |
| `prUrl` | Optional | Alternative PR selector; must match `target_repo` |
| `prTitle`, `prBody` | Generated if omitted | Customize PR metadata |
| `draft` | `true` | Create a draft PR; `false` creates ready-for-review. Updates do not change an existing PR's draft state |

Use one PR selector where possible. If both are supplied, `prNumber` and `prUrl`
must match; an accompanying `branch` must be that PR's head. Do not send a default
branch (`main`, `master`, or the repository's actual default).

Use plain repository URLs for starter defaults. Optional examples:

```text
https://github.com/owner/starter
https://github.com/owner/starter/tree/main
https://github.com/owner/starter/tree/v1.0.0
https://github.com/owner/starter/tree/feature%2Fnew
https://github.com/owner/starter/tree/main/packages/web
https://github.com/owner/starter/commit/<commit-sha>
```

For template branch names containing `/`, encode that slash as `%2F`; unencoded
segments after the ref mean a starter subdirectory. A template `blob` URL is
invalid. A project `blob/.../Projects/<name>/structure.yaml` URL is valid.

## Prepare one input file

Use POSIX `sh`, `curl` and `jq`. Set the destination and recipe from the user's
request; replace example names before executing. Read tokens from runtime
secrets. Do not enable tracing or print headers.

```sh
ORIGIN=${SCAFFOLDER_API_ORIGIN:-https://app-scaffolder.vercel.app}
API="${ORIGIN%/}/api/agent-scaffold"
PROJECT_URL='https://github.com/judigot/scaffolder-files/tree/main/Projects/ORM%20Schema%20-%20Knex'
TARGET_REPO='example-owner/my-app'
TEMPLATE_URL='https://github.com/judigot/template-monorepo'

jq -n --arg project "$PROJECT_URL" --arg target "$TARGET_REPO" '{
  project_url: $project,
  target_repo: $target,
  draft: true,
  schemaInfo: "<@@SCHEMA@@>\n@users:id:n#pk,email:s!u,name:s,created_at:D,updated_at:D\n<@@/SCHEMA@@>"
}' > request.json
```

This schema is an ORM recipe example, not a universal fullstack schema. For
`hono-react`, use the `user`/`session` schema in the main skill. Adapt product
tables and satisfy the selected recipe's filter before calling the API.

## Choose one curl request

Treat these as alternatives, not a script to run from top to bottom. Each call
can write to GitHub. Keep `response.json` so errors and created repository state
remain available. `--fail-with-body` returns a failure exit code on HTTP errors
while preserving their response body. Do not add `--retry`.

### Existing repository, GitHub App, recipe-owned Core/base

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data-binary @request.json --output response.json
```

Omitting `template_repo` uses the recipe's own `$BASE` and Core imports.
For a bundled host recipe, prepare the alternative input first:

```sh
jq 'del(.project_url) | .project = "ORM Schema - Knex"' request.json > bundled-request.json
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data-binary @bundled-request.json --output response.json
```

### Existing repository plus a public starter, GitHub App

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$(jq --arg template "$TEMPLATE_URL" '. + {template_repo: $template}' request.json)" \
  --output response.json
```

### New organization repository, GitHub App

Set `target_repo` in `request.json` to the requested organization and new name.
The App needs permission to create repositories in that organization.

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$(jq --arg template "$TEMPLATE_URL" '. + {template_repo: $template, create_repo: true}' request.json)" \
  --output response.json
```

### New personal or organization repository, PAT

For a personal target, the PAT must belong to that account. This header supplies
GitHub access; it does not replace the Scaffolder bearer key.

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H "X-GitHub-Token: $GITHUB_PAT" \
  -H 'Content-Type: application/json' \
  --data "$(jq --arg template "$TEMPLATE_URL" '. + {template_repo: $template, create_repo: true}' request.json)" \
  --output response.json
```

### Existing repository, PAT

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H "X-GitHub-Token: $GITHUB_PAT" \
  -H 'Content-Type: application/json' \
  --data "$(jq '. + {create_repo: false}' request.json)" \
  --output response.json
```

### Update the same PR

Set `PR_URL` to the returned URL. Repeat the same template selection used in the
original generation. If no request-level template was used, omit `template_repo`.
Remove the PAT header to use the App. Do not create a new destination again.

```sh
PR_URL='https://github.com/example-owner/my-app/pull/1'
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H "X-GitHub-Token: $GITHUB_PAT" \
  -H 'Content-Type: application/json' \
  --data "$(jq --arg pr "$PR_URL" --arg template "$TEMPLATE_URL" '. + {prUrl: $pr, template_repo: $template, create_repo: false}' request.json)" \
  --output response.json
```

Alternatively, use `prNumber` on the same target:

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$(jq --arg template "$TEMPLATE_URL" '. + {prNumber: 1, template_repo: $template, create_repo: false}' request.json)" \
  --output response.json
```

### Named branch and custom PR metadata

```sh
curl -sS --fail-with-body --max-time 120 "$API" \
  -H "Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY" \
  -H 'Content-Type: application/json' \
  --data "$(jq '. + {branch: "refresh-models", prTitle: "Refresh generated models", prBody: "Generated from updated project inputs.", draft: false}' request.json)" \
  --output response.json
```

Use `draft: false` only if the user requested ready-for-review. To select a tag
or starter subdirectory, set `TEMPLATE_URL` accordingly and reuse the appropriate
starter example. Existing Auth0 callers can replace the bearer value with their
Auth0 access token; agents should keep using the agent key.

## Read the response

Require `ok: true` and the expected PR URL/number. A new generated branch normally
returns 201. Reusing a branch/PR, including an identical-tree no-op, returns 200
with `updated: true`. Record these fields when present:

```json
{
  "ok": true,
  "prUrl": "https://github.com/example-owner/my-app/pull/1",
  "prNumber": 1,
  "branch": "scaffolder/demo-ab12",
  "commitSha": "destination-commit",
  "filesCreated": 12,
  "baseBranch": "main",
  "projectName": "demo",
  "targetRepo": "example-owner/my-app",
  "tables": ["users"],
  "updated": false,
  "repoCreated": true,
  "resolvedSha": "starter-source-commit",
  "projectResolvedSha": "recipe-source-commit"
}
```

Distinguish destination `commitSha` from starter `resolvedSha` and recipe
`projectResolvedSha`. Local/bundled sources omit their remote SHA fields.
Do not send response-only fields back as request fields.

## Recover from errors

Read `code`, `error`, `details`, and `installationUrl` before choosing an action.

| Error | Next action |
| --- | --- |
| Network timeout | Inspect the destination repo, branch and PR before retrying; the server may have completed the write |
| 404 from the endpoint | Check the configured origin/deployment; do not guess other hosts |
| 401 | Correct the Scaffolder API credential; a PAT does not replace it |
| 400 `INVALID_GITHUB_TOKEN` | Fix the empty or whitespace-containing PAT header; do not silently omit it |
| Invalid request body / unknown fields | Check field names and whether the deployment contains PR #76; do not drop a requested feature as a workaround |
| `INVALID_SCHEMA`, `SCHEMA_FILTER_FAILED` | Fix the schema or choose the intended compatible recipe; keep required UUID/camelCase columns |
| `PROJECT_NOT_FOUND` | Check the recipe folder; use `details.availableProjects` if supplied |
| `INVALID_REFERENCE`, `INVALID_TEMPLATE_REPO` | Correct the URL, repository root or project path |
| `FILES_REPO_FETCH_FAILED`, `TEMPLATE_SOURCE_UNAVAILABLE`, `TEMPLATE_FETCH_FAILED` | Check source visibility/ref and the error text; respect rate limits or archive-size limits; never substitute another base silently |
| `TEMPLATE_SUBDIRECTORY_NOT_FOUND` | Fix the selected folder; do not fall back to the repository root |
| `TEMPLATE_API_CONFLICT` | Put `replace: [apps/api/**]` in the recipe before layering the Nest API |
| `BUILD_FAILED`, `LEFTOVER_PLACEHOLDER`, `USER_ENV_DETECTED`, `NO_FILES` | Fix generation/configuration; do not create a repo or publish unresolved output manually |
| 409 `REPO_EXISTS` | Verify the destination, then use `create_repo: false`; do not overwrite/delete/recreate it |
| `USER_REPO_CREATE_UNSUPPORTED` | For an agent-key personal creation, use an owner PAT or create the repo separately and install the App |
| `PAT_OWNER_MISMATCH` | Use a PAT belonging to the requested personal owner; do not change ownership silently |
| `PAT_CREATE_REPO_FAILED`, `PAT_PUBLISH_FAILED` | Check token validity, target access, organization restrictions and required permissions; no App fallback |
| App error with `installationUrl` | Have the owner grant App access to that repo, then retry the intended operation |
| Any error with `details.repoCreated: true` | Keep `details.repoUrl`; fix publication/access, then retry with `create_repo: false` |
| `PR_REPO_MISMATCH`, `BRANCH_PR_MISMATCH` | Make target repository and PR/branch selectors agree |
| `PR_NOT_FOUND`, `PR_NOT_OPEN` | Verify the PR; a closed/merged PR needs a new generation branch |
| `PROTECTED_BRANCH`, `BRANCH_UPDATE_FAILED` | Resolve the protected/diverged branch; never force-push |
| `BRANCH_CREATE_FAILED` | Inspect the existing branch; update it if intended, otherwise choose a new generation |

For every retry, preserve the intended source URLs, destination and explicit
credential choice. A new random branch is not a substitute for investigating an
uncertain previous write.
