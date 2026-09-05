---
name: scaffolder
description: Generate an app or schema-based modules through the Scaffolder agent API and return a draft GitHub PR. Use for Scaffolder requests, greenfield projects, public GitHub starters, in-house Core templates, destination repository creation, and regeneration of an existing scaffolder PR. Support GitHub App or request-scoped PAT authentication. Do not clone Scaffolder to use the API.
---

# Scaffolder: requirements to a draft PR

Use `POST /api/agent-scaffold` to combine a project recipe with optional starter
files, generate code, and open or update a PR. Return the PR URL. Keep it draft
unless the user requests a ready-for-review PR. Do not merge it.

Use this for new projects and deliberate schema-based generation into existing
repositories. For ordinary feature work in an already-generated app, edit that
app normally; do not regenerate it just to change a component or fix a bug.

## Read the right reference

- Read [API requests and recovery](references/agent-api.md) before sending a
  request. It contains copyable curl examples, field defaults and error actions.
- Read [Implementation and recipe composition](references/implementation.md)
  when authoring a recipe, debugging a merge, or changing the host implementation.
- When loading this skill over HTTP, resolve these relative links from
  `skills/scaffolder/` in the same `judigot/ai` revision. Do not assume the
  references are already loaded. Do not clone the host to call its API.

These instructions describe the contract implemented by
[Scaffolder PR #76](https://github.com/judigot/scaffolder/pull/76), including
commit `285be7b`. Use a host deployment containing that implementation. A skill
update does not deploy the host. If the host rejects the new fields or still
requires a commit hash, report the version mismatch; do not silently drop the
requested template or change authentication.

## 1. Identify the three locations

| Name | Meaning | Example |
| --- | --- | --- |
| `project_url` | The Scaffolder recipe that says what to generate | `https://github.com/judigot/scaffolder-files/tree/main/Projects/ORM%20Schema%20-%20Knex` |
| `template_repo` | Optional starter files to use as the base | `https://github.com/judigot/template-monorepo` |
| `target_repo` | The destination that receives the generated PR | `judigot/my-app` or `https://github.com/judigot/my-app` |

Treat them as separate inputs. A normal starter repo is not a Scaffolder recipe.
The recipe must exist at `Projects/<name>/structure.yaml` in its files repo.
Both remote sources must be public. The destination may be private.

- Use a plain repository URL for `template_repo` by default. The host resolves
  the actual default branch to a commit internally. Do not ask the user for a SHA.
- Accept optional `/tree/<branch-or-tag>`, `/commit/<sha>`, and
  `/tree/<ref>/<subdirectory>` starter URLs. Encode slashes inside a template
  branch name as `%2F`; later path segments select a subdirectory.
- Accept a project folder URL or a `blob/.../structure.yaml` URL. Preserve the
  user's ref. Encode spaces in project names as `%20`.
- Omit `template_repo` to use the recipe's `$BASE` and Core imports. Do not copy
  an existing starter repository into `scaffolder-files/Core` as a prerequisite.
- Keep `project: "ORM Schema - Knex"` available for an explicitly requested
  bundled host recipe. Prefer `project_url` for caller-owned recipes. Send one
  project selector; if both are present, `project_url` wins.

## 2. Select the operation

| User's goal | Request fields |
| --- | --- |
| Generate into an existing repo | Omit `create_repo` or set it to `false` |
| Create a new repo and generate its first PR (greenfield) | Set `create_repo: true` |
| Update the same open PR | Set `prUrl` or `prNumber`; set `create_repo: false` |
| Reuse a named scaffolder branch | Set `branch`; reuse its open PR if present |
| Start a separate PR | Omit `branch`, `prNumber` and `prUrl` |

Ask for a destination only if the user has not named one. Set `create_repo: true`
only when creating that repository is part of the user's request. Creation makes
it private and initializes a README; generated code is delivered on a PR.

## 3. Select credentials

Authenticate to Scaffolder with `Authorization: Bearer $SCAFFOLDER_AGENT_API_KEY`.
This is not a GitHub credential. Never send a GitHub PAT as that bearer value.

| Destination operation | GitHub credential to use |
| --- | --- |
| Existing personal or organization repo, App installed | Omit `X-GitHub-Token`; use the App |
| New organization repo, App permitted to create repos | Omit `X-GitHub-Token`; use the App |
| New personal repo with an agent API key | Send `X-GitHub-Token: $GITHUB_PAT`; PAT must belong to that personal owner |
| Existing or new repo, caller explicitly chooses PAT | Send `X-GitHub-Token: $GITHUB_PAT` for the whole operation |

A supplied PAT handles creation, commits, branches and PRs. No App installation
is required on that path. It never falls back to the App or a stored token when
the PAT fails. Organization PATs remain subject to organization permissions.

For a fine-grained PAT, provide destination access and Contents/Pull requests
write permissions; creation also needs Administration write. Workflow files
need Workflows write. Ensure the token can access a newly created repo as well.
A classic PAT typically needs `repo` and, for workflow files, `workflow`.

Use the API key already available in the runtime. If missing, request that it be
configured through the runtime's secret mechanism. Do not ask for secret values
in chat or invent them. Never print tokens, log headers, use `curl -v`, or enable
shell tracing around credentials. Do not store a PAT in JSON, recipes or commits.
Do not require a runtime restart unless that platform actually requires one.

Existing Auth0 callers remain supported by the host, but keep agent-key
workflows on the agent key. Do not switch to Auth0 as an error workaround.

## 4. Build and check the input

1. Gather product facts and select the requested recipe. Ask only for facts that
   materially affect generation and are not already known.
2. Read the recipe's `structure.yaml` and satisfy its `$SCHEMA_FILTER`.
3. Build nonempty `schemaInfo` using the compact format below or a valid table
   array. No operation, including greenfield creation, bypasses this input.
4. If switching the starter API from Hono to Nest, ensure the recipe explicitly
   replaces `apps/api/**`; read the implementation reference first. `replace`
   belongs in recipe YAML, not the API JSON body.
5. Send only fields in the API reference. The JSON body is strict: unsupported
   fields such as `github_token`, `replace`, or `visibility` are rejected.

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

## 5. Call once, inspect, then continue

Use `SCAFFOLDER_API_ORIGIN` if set, otherwise
`https://app-scaffolder.vercel.app`; append `/api/agent-scaffold` once.
Use the curl examples in [API requests and recovery](references/agent-api.md).
Capture the response body even on HTTP errors. Do not use automatic retries for
repository creation or PR creation: a timeout can occur after a successful write.

On success, record `prUrl`, `prNumber`, `branch`, `targetRepo`, `repoCreated`,
`resolvedSha` and `projectResolvedSha` when present. Keep the original request's
project/template selections for later regeneration. The host records source
snapshots; the caller does not have to calculate them.

For a schema revision, send the same project/template/target inputs, the new
schema and the returned PR selector; omit `create_repo` or set it to `false`.
Do not create a second PR for the same requested revision. A recipe's remote
base may advance on a later call; use the returned SHA in a source URL only if
an exact replay is needed.

Regeneration is not a general patch editor. Inspect a PR that contains manual
changes before regenerating: the current publisher builds from the destination
default-branch tree, so branch-only files or edits outside the new generated
output can be lost. Prefer ordinary app edits for manual feature work.

If the response says `details.repoCreated: true`, preserve its repository URL.
Fix the reported access/publication problem, then retry with `create_repo: false`.
Never delete the repository or retry creation just to clear that error. After a
network timeout, inspect whether the repo/branch/PR exists before choosing a retry.

Treat a closed/merged PR, wrong destination, protected branch or failed
fast-forward as a specific error to resolve; do not force-push or guess another
host. Follow the recovery table instead of retrying blindly.

## 6. Deliver

Return the PR URL and one checkout command for the destination repository:

```sh
gh pr checkout N
```

Mention a created repository if applicable. Do not claim success from HTTP status
alone: require `ok: true` and the expected PR fields. Do not offer ZIP downloads,
clone Scaffolder to load the tool, create a second GitHub App, or copy generated
files into the app as a fallback unless the user explicitly chooses that route.
