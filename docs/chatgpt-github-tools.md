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

## New repository from a GitHub template

1. Ask only for missing essential information; choose a meaningful user-requested name **without a timestamp**. Check for collision with `get_repo`. Stop on conflicts; never overwrite.
2. Prefer a **verified callable** native `POST /repos/{template_owner}/{template_repo}/generate` tool with body `{owner,name,private:true,include_all_branches:false}`.
3. The October 2026 connected GitHub plugin exposed **no** `generate_repository`, arbitrary authenticated REST request, or workflow-dispatch tool. Reinspect the *current* catalog; do not fabricate them.
4. Look for an **actually connected** authenticated Agent Workspace provisioning action. An imagined API route or documented shell command is not a callable tool.
5. The legacy Agent Workspace PR-comment trigger exists but **the user does not want this mechanism**. Do not use it unless the user explicitly changes that constraint. If neither direct route is callable, report the specific missing capability without declaring the whole architecture impossible.
6. After creation, verify destination owner, private status, default `main`, and complete template file tree before proceeding with feature PR, Neon, and Vercel.

## Failure recovery

A `TypeError`, safety-check rejection, validation error, or permission error has a different cause. Re-discover callable tools, inspect side effects before retrying, check for existing PR/comment/resource, and never issue duplicate privileged authorizations. Distinguish submitted command from actual observed success.

**Reminder:** Documentation alone cannot add a new ChatGPT tool. Do not promise direct provisioning until connector registration and an end-to-end fresh-chat test succeed.
