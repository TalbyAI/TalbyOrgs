# Work Routing

How to decide who handles what.

## Routing Table

| Work Type | Route To | Examples |
|-----------|----------|----------|
| Architecture, boundaries, and review authority | Gandalf | Bounded contexts, event-sourced write model, Orleans grain boundaries, projection strategy, API shape review, reviewer approvals |
| Delivery leadership and feature routing | Aragorn | Break V1 into workstreams, assign org/project/RBAC features, sequence idempotency and observability work, triage cross-team issues |
| Scoped implementation and support coding | Pippin | Controllers, command handlers, projection-backed operational reads, service registration endpoints, small .NET and Orleans implementation tasks under lead review |
| Security, privacy, and trust boundaries | Gimli | RBAC enforcement posture, pre-registered service trust checks, issuer/audience validation, privacy-boundary review, protected-by-default API review |
| Persistence, Marten, and PostgreSQL read/write modeling | Elrond | Marten event store setup, projection storage, PostgreSQL schema and indexing, projection lag diagnostics, idempotency persistence strategy |
| Critical design challenge and risk surfacing | Saruman | Challenge assumptions, highlight risks in event sourcing or authorization design, critique rollout plans; advisory only, not a decision owner |
| Documentation and operational writing | Bilbo | API docs, integration notes, permission namespace guidance, observability/runbook docs, architecture summaries |
| Code review | Gandalf | Review PRs, enforce architecture, check quality, reject weak designs, suggest improvements |
| Testing | Samwise | Behavior-first tests, idempotency and retry coverage, auth decision tests, end-to-end workflow verification, edge cases |
| Scope & priorities | Aragorn | What to build next, work decomposition against the V1 PRD, trade-offs, milestone planning |
| Session logging | Scribe | Automatic — never needs routing |

## Issue Routing

| Label | Action | Who |
|-------|--------|-----|
| `squad` | Triage: analyze issue, assign the right `squad:{member}` label, and set implementation vs review ownership | Aragorn |
| `squad:aragorn` | Lead feature slicing, coordinate multi-agent work, own delivery-level issue resolution | Aragorn |
| `squad:gandalf` | Own architecture review, reviewer gates, design approval, and high-risk technical decisions | Gandalf |
| `squad:pippin` | Pick up contained implementation tasks and follow-up fixes | Pippin |
| `squad:samwise` | Own test strategy, regression validation, and behavior-first coverage work | Samwise |
| `squad:gimli` | Own security/privacy/trust-boundary review tasks | Gimli |
| `squad:elrond` | Own Marten/PostgreSQL/event-store/projection data tasks | Elrond |
| `squad:saruman` | Perform critique and risk review only; advisory, not decision ownership or delivery ownership | Saruman |
| `squad:bilbo` | Own docs, runbooks, API writing, and integration guidance | Bilbo |

### How Issue Assignment Works

1. When a GitHub issue gets the `squad` label, **Aragorn** triages it — analyzing content, assigning the right `squad:{member}` label, and commenting with triage notes.
2. When a `squad:{member}` label is applied, that member picks up the issue in their next session.
3. Members can reassign by removing their label and adding another member's label.
4. The `squad` label is the "inbox" — untriaged issues waiting for lead review.

## Rules

1. **Eager by default** — spawn all agents who could usefully start work, including anticipatory downstream work.
2. **Scribe always runs** after substantial work, always as `mode: "background"`. Never blocks.
3. **Quick facts → coordinator answers directly.** Don't spawn an agent for "what port does the server run on?"
4. **When two agents could handle it**, pick the one whose domain is the primary concern.
5. **"Team, ..." → fan-out.** Spawn all relevant agents in parallel as `mode: "background"`.
6. **Anticipate downstream work.** If a feature is being built, spawn the tester to write test cases from requirements simultaneously.
7. **Issue-labeled work** — when a `squad:{member}` label is applied to an issue, route to that member. Aragorn handles all `squad` (base label) triage, Gandalf handles architecture/review gates, and Saruman remains advisory only.
