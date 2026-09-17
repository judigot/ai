---
name: junit-test-implementation
description: Find Java test coverage gaps, implement JUnit tests, and diagnose failures in existing Maven and Spring projects. Use for scoped backend test additions or maintenance.
---

# JUnit test implementation

Read [Java backend conventions](../../settings/backend-java.md). Adapted from
STP's JUnit skill and its six Cursor commands; no Cursor command installation
is required.

## Inventory and scope

Identify the actual Maven root/module, Java/JUnit versions, test plugins, and
existing controller/service tests. Work within the requested classes or module.
List missing test classes separately from uncovered behavior in existing tests.
Inspect calls and assertions; a matching method name alone does not prove coverage.
Exclude generated MyBatis code, annotation declarations, constant-only enums,
and DTO boilerplate where the project does; include any handwritten behavior.

For substantial work, keep a class/method gap table and a list of created test
classes in an existing ignored scratch directory, or a temporary directory.
Confirm ignore rules rather than assuming `tmp/` is ignored. Reconcile progress
against actual test files; a recorded class name is not proof that work is done.

## Implementation

- Follow the package layout and existing `ClassNameTest` naming convention.
- Test success, invalid inputs, boundaries, and error paths with meaningful
  assertions. Avoid generating tests merely to increase class counts.
- Follow the project's MockMvc setup for controller status/body assertions and
  Mockito setup for isolated service tests. Use annotations supported by its
  installed Spring/JUnit versions.
- Process coherent batches and recheck gaps within the requested scope. Continue
  authorized work without requiring a new user prompt for each batch.
- For a test-only request, keep production code unchanged. If a test reveals a
  production defect, report the failing behavior and proposed fix; do not weaken
  the assertion to make it pass. Existing authorization to fix production code
  still applies. Unrelated failing tests do not expand the task.

## Execution and delivery

Run targeted tests first using the project's Maven wrapper or installed Maven.
For a reactor build, resolve the real module for `-pl` and the real test classes
for `-Dtest`; inspect build dependencies before deciding whether `-am` is needed.
Run the applicable module suite after targeted tests pass.

Diagnose failures as test defects, production defects, or environment failures.
Retry after a meaningful correction; report a blocker when required dependencies
or authority are unavailable. Do not disable tests, bypass CI, or accept a run
with no executed tests as success. Report skipped tests separately. Use temporary
output paths for file-producing tests and the project's integration-test setup
when external services are required.

Review the diff for scope and temporary artifacts. Follow the overlay's delivery
policy and runtime Git permissions; this skill does not authorize commits, pushes,
PRs, or conflict resolution by discarding a branch. Report tests added, covered
behavior, commands/results, and remaining gaps. If a PR is authorized, include
the test-to-production-class mapping and manual testing checklist.
