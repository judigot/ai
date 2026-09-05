---
name: scaffolder
description: Use this skill when the user wants a fast client MVP from app requirements. Build schemaInfo, call the Scaffolder agent API, and open a draft PR on a target GitHub repo. Do not write the default branch. Do not clone or download Scaffolder to load this skill.
---

# Scaffolder (draft PR)

Turn requirements into a generated project on a **draft pull request**. The delivery is the PR, not a ZIP and not a checkout menu.

Read this file and call the API. Do not clone `judigot/scaffolder` or `judigot/scaffolder-files` to follow it.

## When to use

- "Scaffold this app", "generate an MVP", "stand up a client project from a schema"
- User names Scaffolder, `schemaInfo`, `hono-react`, or a `target_repo`

Do **not** use this for ordinary feature work in an already-generated app. Implement in the app repo instead.

## Preconditions

1. `SCAFFOLDER_AGENT_API_KEY` is set in this runtime (Cursor Secret or equivalent). Never print it. Never log the header.
2. Destination write access is in place: either the **Scaffolder GitHub App** is installed on the target repo, or this runtime has a GitHub PAT to send as `X-GitHub-Token` (Cursor Secret such as `GITHUB_PAT`). The PAT is request-scoped, used for destination create/commit/PR only, and is never stored or sent to public source downloads.
3. The user named a `target_repo` (GitHub URL or `owner/repo`). If they did not, ask once.

If the API key is missing, stop. Tell them to add the same value used on the Scaffolder host as a Cursor Secret, then start a **new** Cloud Agent. Do not fall back to Auth0. Do not ask them to paste the key or a PAT into chat.

## Flow

1. Gather enough product facts to name tables (one clarifying question at a time if needed).
2. Build `schemaInfo` (compact string preferred). Empty `{}`, `[]`, or `""` is invalid.
3. `POST` `/api/agent-scaffold` with Bearer auth.
4. Return `prUrl` and one checkout command. Leave the PR **draft**. Do not merge.
5. To iterate on that same draft, call again with `branch` or `prNumber`. Do not open a second PR.

## Build schemaInfo

Prefer compact format (token-cheap). The API also accepts a JSON array of tables.

```
<@@SCHEMA@@>
@users:id:n#pk,email:s!u,hashed_password:s,name:s,created_at:D,updated_at:D|>posts
@posts:id:n#pk,user_id:n>users,title:s,body:s,created_at:D,updated_at:D|<users
<@@/SCHEMA@@>
```

Table: `@table_name:columns|relationships`  
Column: `name:type[?][!u][#pk][>fk_table]`

| Code | Type |
| --- | --- |
| `:s` | string |
| `:n` | number |
| `:b` | boolean |
| `:D` | Date |
| `:o` | object |
| `:u` or `:uuid` | uuid |

Modifiers: `?` nullable, `!u` unique, `#pk` primary key, `>table` foreign key to `table.id`.  
Relationships after `|`: `|<a,b` belongsTo, `|>a,b` hasMany, `|^a` hasOne, `|*a` belongsToMany.

Always apply without asking: hashed passwords (`hashed_password`, never plain `password`), unique email, `id` PK, timestamps, pivot tables for many-to-many.

JSON `data_type` values: `string`, `number`, `boolean`, `Date`, `object`, `uuid`. Compact codes are `s/n/b/D/o/u` (`:uuid` is an alias for `:u`). Table names stay snake_case (`^[a-z][a-z0-9_]*$`). Column names are identifiers (`^[A-Za-z][A-Za-z0-9_]*$`): snake_case or camelCase. Use camelCase when the project filter or Lucia-style auth columns need it (`userId`, `createdAt`).

### Identify the project with `project_url`

`project_url` is a **GitHub URL** to the project folder inside the caller's **scaffolder-files** repository — not a closed catalog name. Each developer hosts their own files repo (configs, `Projects/<name>/structure.yaml`, templates). Encode the project path in the URL. There is no product-default files repo.

- Files source + project: `https://github.com/<owner>/<scaffolder-files>/tree/<ref>/Projects/<name>`
- Destination app repo is a different field: `target_repo`

Example: `https://github.com/judigot/scaffolder-files/tree/main/Projects/ORM%20Schema%20-%20Knex`  
points at the `ORM Schema - Knex` folder in that files repo. Spaces may be literal or `%20`. A `blob/.../structure.yaml` URL is also accepted. Any public `owner/repo` in `project_url` is fetched from GitHub.

Legacy: optional `project` may still be a folder name such as `hono-react` or `ORM Schema - Knex` and reads bundled host files. Do not use `project` in new calls.

### Project: `hono-react`

Default fullstack MVP project (URL below). Its `$SCHEMA_FILTER` requires all of:

- table `user` (singular, not `users`)
- table `session`
- `user.id.data_type=uuid`
- `session.userId` has a foreign key

Send uuid ids and camelCase `session.userId`. Do **not** retry `hono-react` with numeric ids (filter fails). Example:

```
<@@SCHEMA@@>
@user:id:u#pk,email:s!u,hashed_password:s,createdAt:D,updatedAt:D|>session
@session:id:s#pk,userId:u>user,expiresAt:D|<user
<@@/SCHEMA@@>
```

Equivalent JSON uses `"data_type": "uuid"` and `"column_name": "userId"`. If a deployed host still returns `INVALID_SCHEMA` for uuid or camelCase, the API is behind this contract — do not rewrite the schema to numeric ids. Do **not** invent a local file write into the target repo.

## Call the API

Origin: `SCAFFOLDER_API_ORIGIN` if set, else `https://app-scaffolder.vercel.app`.  
Path: `POST /api/agent-scaffold`.

Never print the token. Never use `curl -v`. Put `schemaInfo` last in the JSON.

```sh
# create (GitHub App publication)
curl -sS --max-time 120 \
  -X POST "https://app-scaffolder.vercel.app/api/agent-scaffold" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SCAFFOLDER_AGENT_API_KEY}" \
  -d '{"project_url":"https://github.com/judigot/scaffolder-files/tree/main/Projects/ORM%20Schema%20-%20Knex","target_repo":"https://github.com/judigot/bookingwars","draft":true,"schemaInfo":"<@@SCHEMA@@>\n@users:id:n#pk,email:s!u,name:s,created_at:D,updated_at:D\n<@@/SCHEMA@@>"}'
```

For a new personal destination, or to publish with a PAT instead of the App, add `-H "X-GitHub-Token: ${GITHUB_PAT}"`. Keep the PAT out of JSON, URLs, and chat.

```sh
# update PR 2
curl -sS --max-time 120 \
  -X POST "https://app-scaffolder.vercel.app/api/agent-scaffold" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${SCAFFOLDER_AGENT_API_KEY}" \
  -d '{"project_url":"https://github.com/judigot/scaffolder-files/tree/main/Projects/ORM%20Schema%20-%20Knex","target_repo":"https://github.com/judigot/bookingwars","draft":true,"prNumber":2,"schemaInfo":"<@@SCHEMA@@>\n@users:id:n#pk,email:s!u,name:s,created_at:D,updated_at:D\n<@@/SCHEMA@@>"}'
```

Default fullstack MVP (`hono-react`) uses the same shape:

```json
{
  "project_url": "https://github.com/judigot/scaffolder-files/tree/main/Projects/hono-react",
  "target_repo": "https://github.com/judigot/bookingwars",
  "schemaInfo": "<@@SCHEMA@@>\n@user:id:u#pk,email:s!u,hashed_password:s,createdAt:D,updatedAt:D|>session\n@session:id:s#pk,userId:u>user,expiresAt:D|<user\n<@@/SCHEMA@@>"
}
```

`target_repo` may be `owner/repo`. Do not confuse it with `project_url` (files repo + project path).

### Greenfield vs bookingwars

- **Existing app** (`bookingwars` or any repo the user already named): omit `create_repo`. Open or update a draft PR on that repo. Do not recreate it.
- **New dest repo**: set `create_repo: true`. The host generates first, then creates. Org owners can be created by the Scaffolder GitHub App (private + `auto_init`) without a PAT. Personal owners need `X-GitHub-Token` (a PAT belonging to that user) or an Auth0 caller with a stored GitHub token. If the API returns `USER_REPO_CREATE_UNSUPPORTED`, either add a PAT secret and retry with the header, or create the empty private repo first, install the App on it, then call again with `create_repo` omitted. Never paste a PAT into chat or JSON. Never create a second GitHub App. Collision is `REPO_EXISTS` — do not overwrite. When the PAT header is present, it is used for create and for PR publication; the host does not fall back to the App.
- **Live starter**: optional `template_repo` is an ordinary public GitHub repo URL (`https://github.com/owner/repo`). Do **not** look up a commit SHA. The host resolves the repo's actual default branch from GitHub metadata (do not assume `main`), fetches one commit snapshot, and returns `resolvedSha`. Optional `/tree/<branch|tag|sha>` remains valid for advanced use; `main` is not an error. Other owners' public repos are accepted. If the URL includes a subdirectory, the host uses that folder or returns `TEMPLATE_SUBDIRECTORY_NOT_FOUND` — it never silently downloads the repo root. Omit `template_repo` (and recipe `$BASE`) to keep today's bundled `/Core/template-monorepo`.
- Recipe authors may set `$BASE: https://github.com/judigot/template-monorepo` or `source:` plus `replace: [apps/api/**]`. Request `template_repo` overrides `$BASE`. A live Hono `apps/api` plus Nest without `replace:` fails (`TEMPLATE_API_CONFLICT`).

```json
{
  "project_url": "https://github.com/judigot/scaffolder-files/tree/main/Projects/template-monorepo",
  "template_repo": "https://github.com/judigot/template-monorepo",
  "target_repo": "judigot/booking-app",
  "create_repo": false,
  "schemaInfo": "<@@SCHEMA@@>\n@products:id:n#pk,name:s,price:n\n<@@/SCHEMA@@>"
}
```

Optional: `branch`, `prNumber`, `prUrl`, `prTitle`, `prBody`, `draft`, `template_repo`, `create_repo`.

- Omit `branch` and `prNumber` for a **new** unique `scaffolder/<project>-<id>` branch and a **new draft** PR.
- Send `branch` to commit again on that existing `scaffolder/…` branch (fast-forward only). If an open PR already exists for that head, the API returns **that** PR. If the branch exists with no PR, it opens a **draft** PR (it does not mark a ready PR as draft).
- Send `prNumber` (positive int) to resolve the head branch on `target_repo`, then the same update path. `prUrl` (`https://github.com/owner/repo/pull/N`) is an alternative to `prNumber`. If both `prNumber` and `prUrl` are sent, they must be the same PR. If both `branch` and `prNumber` are sent, they must refer to the same head or the API returns 400.
- Names without the `scaffolder/` prefix get that prefix. Spaces in auto or explicit names are slugged to hyphens.
- `draft: false` only if the user asked for a ready-for-review PR. Updates never flip an existing PR from draft to ready.

Never send `branch` of `main`, `master`, or the repo default. The API refuses those (`PROTECTED_BRANCH`). Never force-push. Never write the default branch.

### Iterate on the same PR

After the first `201`, keep `prUrl` / `prNumber` / `branch` and call again with the new `schemaInfo`:

```json
{
  "project_url": "https://github.com/judigot/scaffolder-files/tree/main/Projects/hono-react",
  "target_repo": "https://github.com/judigot/bookingwars",
  "prNumber": 2,
  "schemaInfo": "<@@SCHEMA@@>\n@user:id:u#pk,email:s!u,hashed_password:s,createdAt:D,updatedAt:D|>session\n@session:id:s#pk,userId:u>user,expiresAt:D|<user\n<@@/SCHEMA@@>"
}
```

That adds a new commit on the existing `scaffolder/…` branch (parent = current HEAD) and returns the **same** `prNumber` / `prUrl`. Prefer `prNumber` (canonical). `branch` is also enough. Do not create a second PR for a schema tweak.

If the generated tree matches HEAD, the API returns the current `commitSha` and does not create an empty commit.

A **closed or merged** PR cannot be updated (`400 PR_NOT_OPEN`). Open a new unique branch instead. If history diverged so a force-push would be required, the API fails (`400 BRANCH_UPDATE_FAILED`) and does not `--force`.

## Success

First create: `201`. Update or identical-tree no-op: `200`. Same body either way (`updated: true` on reuse):

```json
{
  "ok": true,
  "prUrl": "https://github.com/owner/repo/pull/N",
  "prNumber": 1,
  "branch": "scaffolder/hono-react-ab12cd34",
  "commitSha": "...",
  "filesCreated": 1,
  "baseBranch": "main",
  "projectName": "hono-react",
  "targetRepo": "owner/repo",
  "tables": ["user", "session"],
  "updated": false,
  "resolvedSha": "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}
```

Tell the user the PR URL and exactly one checkout:

```sh
gh pr checkout N
```

Do not offer ZIP download. ZIP is a human UI fallback on the Scaffolder site, not the agent path.

## Errors (do not retry blindly)

| Status / code | What to do |
| --- | --- |
| 404 | Origin is wrong. Stop. Do not guess other hosts. |
| 401 | Key missing or mismatch. Stop. Do not print the key. |
| 400 `INVALID_SCHEMA` | Fix schemaInfo. Empty payload is invalid. |
| 400 `SCHEMA_FILTER_FAILED` | Schema does not match the project filter. See `hono-react` above. |
| 400 `PROJECT_NOT_FOUND` | The URL path (or legacy name) is not a folder in that files repo. Use a name from `details.availableProjects`. |
| 400 `FILES_REPO_FETCH_FAILED` | Could not download that public files repo. Check the `project_url` owner/repo/ref. |
| 400 `INVALID_REFERENCE` | `project_url` must be a GitHub tree/blob URL with `Projects/<name>`. Legacy `project` may be a folder name. |
| 400 `PROTECTED_BRANCH` | Pick a non-default `scaffolder/…` branch. |
| 400 `BRANCH_CREATE_FAILED` | Unique new name collided (no force-push). Omit `branch` to get another unique name, or send the existing `branch` / `prNumber` to update. |
| 400 `BRANCH_UPDATE_FAILED` | Fast-forward update failed (would need force-push). Stop. Do not retry with `--force`. |
| 400 `PR_NOT_OPEN` | That PR is closed or merged. Open a new unique `scaffolder/…` branch. |
| 400 `PR_NOT_FOUND` | `prNumber` does not exist on `target_repo`. |
| 400 `PR_REPO_MISMATCH` | `prUrl` is not on `target_repo`. |
| 400 `BRANCH_PR_MISMATCH` | `branch` and `prNumber` do not refer to the same head. |
| 403 + `installationUrl` | Target owner must install the Scaffolder GitHub App on that repo. |
| 400 `INVALID_TEMPLATE_REPO` | `template_repo` / `$BASE` is not a github.com repository URL. Use `https://github.com/owner/repo`. |
| 400 `TEMPLATE_SOURCE_UNAVAILABLE` | The public starter repo or ref could not be resolved. Check owner/repo/visibility. |
| 400 `TEMPLATE_SUBDIRECTORY_NOT_FOUND` | The URL named a subdirectory that is not in that snapshot. Do not retry with the repo root unless the user asked for the root. |
| 400 `TEMPLATE_API_CONFLICT` | Live Hono `apps/api` plus Nest without `replace: [apps/api/**]`. Use the Nest recipe or strip first. |
| 400 `USER_REPO_CREATE_UNSUPPORTED` | Personal create without `X-GitHub-Token` (and no stored Auth0 GitHub token). Send a PAT header, or create the user repo first, install the App, retry without `create_repo`. |
| 400 `INVALID_GITHUB_TOKEN` | `X-GitHub-Token` was empty or contained whitespace. Fix the secret; do not fall back to the App on the same request. |
| 403 `PAT_OWNER_MISMATCH` | The PAT is not the destination personal account. Use that owner's PAT. |
| 403 `PAT_CREATE_REPO_FAILED` | PAT could not create the dest. Check validity, owner access, and Administration write. |
| 403 `PAT_PUBLISH_FAILED` | PAT could not open or update the PR. Check Contents and Pull requests write (Workflows write if generating workflows). If `details.repoCreated` is true, retry with `create_repo` omitted. |
| 409 `REPO_EXISTS` | `create_repo` hit an existing dest. Do not overwrite. Call again with `create_repo` omitted. |

## Do not

- Write, force-push, or merge `main` / `master` / the default branch
- Force-push an existing scaffolder branch (update with `branch` or `prNumber` instead)
- Print `SCAFFOLDER_AGENT_API_KEY`, `X-GitHub-Token`, Auth0 tokens, or the GitHub App private key
- Put a PAT in JSON, URLs, recipe files, or chat
- Use Auth0 as the agent login
- Create a second GitHub App
- Clone Scaffolder to "load the tool"
- Look up commit SHAs for `template_repo` or `project_url` (the host resolves snapshots)
- Apply generated files by copying into a local clone unless the user explicitly asked to skip the API
