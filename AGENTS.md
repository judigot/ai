# Agent instructions

This repository provides an agent workflow overlay. When maintaining `judigot/ai`,
read the current checkout. Otherwise keep the user's app as the working project.
The README is explanatory; reading it is not required to load these instructions.

## Loading policy

1. In consuming projects, try reading this file remotely from
   `https://raw.githubusercontent.com/judigot/ai/main/AGENTS.md`, then every required
   file below. Use the actual file requests to test access; no separate connectivity
   probe is needed.
2. Only if a required remote file cannot be read, use `~/ai` as the local
   fallback. If absent, automatically attempt a shallow clone of `judigot/ai` on
   `main` into `~/ai`, using available GitHub transport and credentials. If it
   exists, verify that it is a checkout of `judigot/ai` before reading it. Do not
   overwrite another directory, discard edits, or reset an existing checkout.
   This fallback needs no additional confirmation, subject to environment permissions.
3. Read `~/ai/AGENTS.md` and all required files from that checkout, even if some
   files were already fetched remotely. Resolve subsequent overlay references
   there. Report the path, commit SHA, any local modifications, and that freshness
   is unverified if remote access failed. Try remote loading again next session;
   an existing clone never takes priority over accessible remote instructions.
4. If neither remote loading nor a usable `~/ai` checkout is available, report
   the failures without credentials and request restored access or a usable copy
   at `~/ai`. Cloning also needs network access. Do not claim successful loading
   or proceed with work that depends on missing instructions.

Do not create or modify project files to install this overlay: no project loader,
vendored instructions, or project-local clone. Supply the bootstrap procedure via
agent-level instructions or the standalone [initialization prompt](prompts/prompt-init-chat.md).
It must be available before the remote request; a rule only on an inaccessible
remote cannot bootstrap itself. Reading the README is not required.

The clone fallback applies to `judigot/ai` only. Third-party skills remain links
only, as specified in `settings/references.md`.

## Required instructions

Read all these files from the same source or checkout as this `AGENTS.md`:

- settings/rules.md
- settings/workflow.md
- settings/stack.md
- settings/references.md
