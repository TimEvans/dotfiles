# Issue tracker: Beads

Issues for this repo live in the Beads database at the root of its constellation
vault `magnetic-rose` (`../../.beads`). `.beads/redirect` in this repo points `bd`
there, so every `bd` command below works from this directory. Do not run `bd init` here.

## Conventions

- **Find work**: `bd ready --json` lists open issues with no open blockers.
- **Read an issue**: `bd show <id> --json`.
- **Create an issue**: `bd create "<title>" -t task -p 2 --json`. Use `-t epic` for a map (see below).
- **Claim**: `bd update <id> --claim --json`, before any work. Assignee is the claim.
- **Comment**: `bd comment <id> "<text>"`.
- **Labels**: `bd label add <id> <label>` / `bd label remove <id> <label>`.
- **Block**: `bd dep add <blocked-id> <blocking-id>` (the second issue blocks the first).
- **Close**: `bd close <id> --reason "<one-line answer>"`.
- **Sync**: `bd dolt push` at the end of a session that wrote issues.

Issue IDs are hash-based (`magnetic-rose-a1b2`). Refer to issues by title in prose; the id rides
inside the link.

## When a skill says "publish to the issue tracker"

Create a Beads issue with `bd create`. Specs and plans are markdown in the vault, not issue
bodies: put the file path in the issue description.

## When a skill says "fetch the relevant ticket"

Run `bd show <id> --json`.

## Wayfinding operations

Used by `/wayfinder`. The **map body** is a markdown file in the vault; the **tickets** are Beads
issues. A fact lives in exactly one of them.

- **Map**: the file `../../epics/<epic-id>-<slug>.md` holds Destination, Notes, Decisions so far,
  Not yet specified, Out of scope. It is mirrored by one Beads epic (`bd create "<title>" -t epic`)
  labelled `wayfinder:map` whose description is only the map file's path. Rewrite the file every
  session; never restate a decision in it, only gist and link.
- **Child ticket**: `bd create "<question title>" -t task --json`, then
  `bd dep add <child> <epic> --type parent-child`. Label with `wayfinder:<type>`
  (research, prototype, grilling, task). The body is the question only.
- **Blocking**: `bd dep add <blocked> <blocking>` (default type `blocks`).
- **Frontier**: `bd ready --json` filtered to the epic's children; the first unassigned one wins.
- **Claim**: `bd update <id> --claim`.
- **Resolve**: `bd comment <id> "<answer>"`, then `bd close <id> --reason "<gist>"`, then append
  `- [<title>](bd:<id>) - <gist>` under Decisions so far in the map file.
- **Out of scope**: close the ticket with `--reason "out of scope: <why>"` and add one line to the
  map's Out of scope section.
