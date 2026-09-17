# Java backend conventions

Use only for an existing Java backend. This profile does not replace the default
TypeScript/Hono stack. Adapted from STP's English and Japanese backend rules;
see [provenance](../docs/stp-extraction.md).

- Follow existing Java package structure and import groups. Use PascalCase for
  classes/interfaces, camelCase for methods/fields, and UPPER_SNAKE_CASE for
  constants. The TypeScript `I` interface prefix does not apply to Java.
- Use named constants or enums for domain values, explicit null handling,
  `Optional` return values where the API supports them, and `final` for values
  intended to be immutable.
- Use `var` where supported and the type remains clear. Prefer streams, lambdas,
  or method references for readable collection transformations; retain loops
  when they express control flow more clearly.
- Document public contracts and non-obvious behavior with JavaDoc. In localized
  test suites, use English camelCase method names and localized `@DisplayName`;
  keep any corresponding JavaDoc consistent.

## HTTP contracts

In Spring controllers, follow the application's explicit `ResponseEntity`
pattern and central exception mapping. Return statuses matching the outcome:
creation 201, success with a body 200, success without a body 204, invalid input
400, unauthenticated 401, forbidden 403, missing resource 404, conflict 409,
business validation 422 where the contract uses it, unexpected failure 500,
and temporary unavailability 503. Do not return success statuses for errors.

Inspect the frontend API client as well as the controller when changing a
contract: field names, nullability, error codes, and validation messages must
agree. Test status and body together, including failure paths.

## Tests

Use [junit-test-implementation](../skills/junit-test-implementation/SKILL.md)
for JUnit coverage gaps or test maintenance. Discover the Maven module and
existing test conventions rather than copying STP's module names. Keep generated
code exclusions explicit, and separate unit tests from integration tests that
require databases or report infrastructure.
