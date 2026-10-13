# ChatGPT GitHub tool cookbook (low-tier agents)

This is a concrete execution checklist. Do not skip steps, invent connectors, or mark unverified work complete. Read `judigot/agent-workspace/docs/chatgpt-github-tools.md` for the authoritative, detailed commands and security constraints.

## Discover tools first

If `functions.exec` is available, inspect `ALL_TOOLS.filter(t => t.name.startsWith("mcp__GitHub__"))`. Read a matching tool's declared schema and call `tools.mcp__GitHub__TOOL_NAME({...})`. Otherwise use your client's normal plugin discovery. Test callability before concluding a tool is missing.

## Existing GitHub plugin operations

| Objective | Call this tool | Required input |
| --- | --- | --- |
| Check repository | `mcp__GitHub__get_repo` | `repository_full_name` |
| Read a file | `mcp__GitHub__fetch_file` | `repository_full_name, path, ref` |
| Create feature branch | `mcp__GitHub__create_branch` | `repository_full_name, branch_name, base_ref` |
| Add file | `mcp__GitHub__create_file` | `repository_full_name, branch, path, content, message` |
| Edit file | `mcp__GitHub__update_file` | same plus `sha` from `fetch_file` |
| Open PR | `mcp__GitHub__create_pull_request` | `repository_full_name, head, base, title, body` |
| Read PR | `mcp__GitHub__get_pr_info` | `repository_full_name, pr_number` |
| Find existing PR | `mcp__GitHub__search_prs` | `query, repository_full_name` |
| Read PR comments | `mcp__GitHub__fetch_issue_comments` | `repo_full_name, issue_number` |
| Post PR conversation comment | `mcp__GitHub__add_comment_to_issue` | `repo_full_name, pr_number, comment` |
| Merge PR (only with authorization) | `mcp__GitHub__merge_pull_request` | `repository_full_name, pr_number, merge_method, expected_head_sha` |

Example tool calls (through `functions.exec`, only if it exists in the active runtime):

```js
const repo = "judigot/example";
const existing = await tools.mcp__GitHub__get_repo({repository_full_name:repo});
const branch = await tools.mcp__GitHub__create_branch({
  repository_full_name:repo, branch_name:"feat/posts", base_ref:"main"
});
const pr = await tools.mcp__GitHub__create_pull_request({
  repository_full_name:repo, head:"feat/posts", base:"main",
  title:"feat: posts CRUD", body:"Summary, tests, and manual verification"
});
text({repository:existing.result.repository_full_name, pr:pr.result.url});
```

For adding/updating files, use the declared `create_file` or `fetch_file` + `update_file` schema; do not omit the old file's `sha`. To comment on an ordinary PR:

```js
const comments = await tools.mcp__GitHub__fetch_issue_comments({
  repo_full_name:"judigot/example", issue_number:123
});
const posted = await tools.mcp__GitHub__add_comment_to_issue({
  repo_full_name:"judigot/example", pr_number:123,
  comment:"Verified implementation against the acceptance tests."
});
text(posted.result.id);
```

**Never use the second call as a privileged workflow trigger without explicit task authorization and explicit permission for that trigger.**

## Preferred: create a private repository with no merge or PR comments

Once `judigot/agent-workspace/.github/workflows/repository-provision-on-pr.yml` is installed on `main`, follow these exact steps for new repositories:

1. Confirm current-chat owner authorization; choose a descriptive name like `posts-crud` (no timestamps).
2. `mcp__GitHub__get_repo({repository_full_name:"judigot/posts-crud"})`: stop if it already exists.
3. `mcp__GitHub__create_branch({repository_full_name:"judigot/agent-workspace",branch_name:"provision/repository-posts-crud",base_ref:"main"})`.
4. `mcp__GitHub__create_file({repository_full_name:"judigot/agent-workspace",branch:"provision/repository-posts-crud",path:".agent/repository-requests/create.json",content:'{"name":"posts-crud","private":true,"template":"judigot/template-monorepo"}',message:"chore: request private posts-crud repository"})`.
5. `mcp__GitHub__create_pull_request({repository_full_name:"judigot/agent-workspace",head:"provision/repository-posts-crud",base:"main",title:"chore: provision posts-crud repository",body:"Owner-authorized declarative provisioning request. Do not merge.",draft:false})`.
6. **Stop editing this request. Do not merge it or post comments.** Opening the owner-authored PR triggers trusted Actions on the default branch with the existing server-side PAT. Check the actual Actions run, then `get_repo` for the destination; verify visibility and `main`. If no run or missing resource, report the missing evidence and do not blindly retry.

**Before using this route**, confirm the trusted workflow exists on `main` via `mcp__GitHub__fetch_file`. If not installed, report the one-time setup requirement. PR comments and custom API registration are not required for this route. Full source, safety, verification, and failure-handling requirements: `judigot/agent-workspace/docs/owner-pr-repository-provisioning.md`.

## Optional: separate repository provisioning Action (only if connected)

Agent Workspace implementation PR: `judigot/agent-workspace#117`. The intended ChatGPT Action **operation ID** is `createRepositoryFromTemplate`, described by `judigot/agent-workspace/docs/openapi/repository-provisioning.yaml`. It provisions a **private** `judigot` repository from `judigot/template-monorepo`, accepting `name` and optional `private: true`. It never appends timestamps.

1. First inspect the **current ChatGPT tool catalog**. If, and only if, a connected and authenticated tool exposes `createRepositoryFromTemplate`, read its schema. Confirm with the user before creating an external repository. Call with a descriptive repository name and `private: true`.
2. After its response, call `mcp__GitHub__get_repo` on the returned repository and compare the complete generated main tree against the selected template baseline. Continue with a feature PR only after verifying creation.
3. If the Action is **not actually connected**, do not invent its tool handle, send an unauthenticated HTTP request, or claim it ran. A source-code route, merged PR, and OpenAPI YAML are not enough for a fresh chat to invoke the operation.
4. Existing GitHub tools handle branches, files, PRs, and ordinary comments as described below. Never substitute the legacy owner-command PR-comment **execution trigger** because the user has rejected that mechanism for provisioning.
5. A timeout or ambiguous error requires checking the intended repository's existence before any retry; never rename, delete, or duplicate resources automatically.

**Deployment prerequisites** (operator action, not an agent assumption): merge and deploy the reviewed endpoint; set the scoped provisioner authentication and GitHub token on the server; register and authenticate the ChatGPT Action; require confirmation for this consequential operation; pass an end-to-end fresh-chat test. See `judigot/agent-workspace/docs/chatgpt-repository-provisioning.md`.

## Existing connected plugin cannot directly call template generation

The GitHub plugin's direct template-generation endpoint was not exposed in October 2026. **This does not block provisioning** when the trusted `Owner PR Repository Provisioning` workflow exists on Agent Workspace's `main`. Follow the **Preferred: create a private repository with no merge or PR comments** steps above. A separate ChatGPT Action is optional and does not need to be connected. If that trusted workflow is absent, report the one-time setup requirement.

## Failure recovery

A `TypeError`, safety-check rejection, validation error, or permission error has a different cause. Re-discover callable tools, inspect side effects before retrying, check for existing PR/comment/resource, and never issue duplicate privileged authorizations. Distinguish submitted command from actual observed success.

**Reminder:** The existing connected GitHub tools can open a declarative request PR; no custom connector is needed for that route. A direct provisioning API requires separate registration, but is optional.
