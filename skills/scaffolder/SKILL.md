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
2. The **Scaffolder GitHub App** is installed on the target repo (selected repositories, not every repo on GitHub).
3. The user named a `target_repo` (GitHub URL or `owner/repo`). If they did not, ask once.

If the API key is missing, stop. Tell them to add the same value used on the Scaffolder host as a Cursor Secret, then start a **new** Cloud Agent. Do not fall back to Auth0. Do not ask them to paste the key into chat.

## Flow

1. Gather enough product facts to name tables (one clarifying question at a time if needed).
2. Build `schemaInfo` (compact string preferred). Empty `{}`, `[]`, or `""` is invalid.
3. `POST` `/api/agent-scaffold` with Bearer auth.
4. Return `prUrl` and one checkout command. Leave the PR **draft**. Do not merge.

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

Default fullstack MVP project. Its `$SCHEMA_FILTER` requires all of:

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

Origin: `SCAFFOLDER_API_ORIGIN` if set, else `https://scaffolder.dev`.  
Path: `POST /api/agent-scaffold`.

```sh
# Token stays in the environment. Do not echo it.
curl -sS -X POST "${SCAFFOLDER_API_ORIGIN:-https://scaffolder.dev}/api/agent-scaffold" \
  -H "Authorization: Bearer ${SCAFFOLDER_AGENT_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @payload.json
```

Body:

```json
{
  "schemaInfo": "<@@SCHEMA@@>\n@example:id:n#pk,created_at:D,updated_at:D\n<@@/SCHEMA@@>",
  "project": "https://github.com/judigot/scaffolder-files/tree/main/Projects/hono-react",
  "target_repo": "https://github.com/judigot/bookingwars"
}
```

`project` may also be `hono-react` or `Projects/hono-react`. `target_repo` may be `owner/repo`.

Optional: `branch`, `prTitle`, `prBody`, `draft`. Defaults: unique `scaffolder/<project>-<id>`, draft `true`. Names without the `scaffolder/` prefix get that prefix. `draft: false` only if the user asked for a ready-for-review PR.

Never send `branch` of `main`, `master`, or the repo default. The API refuses those.

## Success

`201`:

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
  "tables": ["user", "session"]
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
| 400 `PROJECT_NOT_FOUND` | Use a name from `details.availableProjects`. |
| 400 `PROTECTED_BRANCH` | Pick a non-default `scaffolder/…` branch. |
| 400 `BRANCH_CREATE_FAILED` | Branch already exists (no force-push). Choose a new name. |
| 403 + `installationUrl` | Target owner must install the Scaffolder GitHub App on that repo. |

## Do not

- Write, force-push, or merge `main` / `master` / the default branch
- Force-push an existing scaffolder branch
- Print `SCAFFOLDER_AGENT_API_KEY`, Auth0 tokens, or the GitHub App private key
- Use Auth0 as the agent login
- Create a second GitHub App
- Clone Scaffolder to "load the tool"
- Apply generated files by copying into a local clone unless the user explicitly asked to skip the API
