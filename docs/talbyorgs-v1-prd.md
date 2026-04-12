# TalbyOrgs V1 Product Requirements Document

## Problem Statement

TalbyOrgs is an internal control-plane service that gives Talby products a shared, reliable source of truth for organizational boundaries and authorization state. Product teams need a stable way to answer questions such as who belongs to an organization, who owns it, which projects exist under it, which permissions are globally defined, which roles bundle those permissions, and whether a principal should be allowed to perform an action in an organization or project.

The problem is not basic user management. Authentication already belongs to external identity providers. The V1 challenge is to establish a clean separation of responsibilities:

- external identity providers authenticate humans and services
- TalbyOrgs materializes principals and owns organization and authorization state
- TalbyOrgs answers authorization decisions from projection-backed state
- client services remain responsible for enforcing Talby authorization decisions in their own request pipelines

Without this service, each product would drift into its own tenant model, permission catalog, ownership rules, and authorization checks. That would create inconsistent access behavior, weak auditability, fragmented onboarding, and high integration cost whenever a new product or service needs organizational and RBAC support.

V1 must prove that TalbyOrgs can be depended on as a shared internal backbone that is auditable, observable, horizontally scalable, privacy-conscious, and disciplined enough not to collapse into a general-purpose identity system.

## Solution

TalbyOrgs V1 will provide a shared internal service that:

- materializes a Talby human principal from each authenticated external human identity
- creates a personal organization for every authenticated human principal on first successful sign-in
- manages non-personal organizations, memberships, projects, roles, role assignments, permission definitions, invitations, and trusted service registrations
- supports a global permission catalog made up of Talby-owned built-in permissions and governed service-registered permissions
- supports immutable built-in roles and tenant-defined custom roles built from the global permission catalog
- answers authorization questions for organization scope and project scope using eventually consistent projections
- persists all authoritative domain changes through an event-sourced write model backed by PostgreSQL
- stores privacy-sensitive profile data outside the immutable event ledger using removable storage linked by reference
- exposes REST as the primary V1 integration surface for mutations and operational queries

From a user perspective, TalbyOrgs should make onboarding deterministic, ownership explicit, project access deliberate, service integrations governed, and authorization answers predictable.

## Goals

- Establish TalbyOrgs as the system of record for organizations, memberships, projects, roles, role assignments, service registrations, and permission registrations.
- Ensure every authenticated human principal has a stable personal organization that can act as a home tenant.
- Support organization-scoped and project-scoped RBAC with clear owner override semantics.
- Provide a governed path for trusted internal services to register permissions inside owned namespaces.
- Provide authorization decision APIs that return allow or deny and can optionally explain the reasoning.
- Preserve a durable, auditable event ledger while keeping removable personal data outside immutable storage.
- Make the platform observable and operationally diagnosable through OpenTelemetry-based signals.
- Make retry behavior safe through idempotent write contracts and duplicate-intent protections.
- Establish behavior-first testing patterns for commands, projections, authorization, and API contracts.

## Non-Goals

- Acting as a primary authentication system for humans or machines
- Owning passwords, MFA, credential issuance, or session management
- Supporting cross-provider identity linking in V1
- Supporting ABAC, policy DSLs, or conditional authorization rules in V1
- Supporting arbitrary scope hierarchies beyond organization and project
- Supporting cross-organization project sharing or project transfer
- Supporting tenant-specific permission definitions
- Supporting dynamic service onboarding without prior registration and governance
- Guaranteeing strong-consistency authorization reads in V1
- Offering multiple equivalent write surfaces across REST, gRPC, GraphQL, and realtime protocols
- Exposing a public audit-history product feature in V1
- Supporting editable local profiles that override identity-provider-owned attributes

## Users and Stakeholders

1. Platform operators who run, monitor, and secure TalbyOrgs.
2. Product teams integrating their applications with TalbyOrgs for permission registration and authorization decisions.
3. Organization owners who manage tenant structure, membership, ownership, and access delegation.
4. Organization members who need predictable access to the organizations and projects they belong to.
5. Internal developers building automation or service-to-service workflows on top of TalbyOrgs.
6. Security and compliance stakeholders who require auditability, governance, and clear data-retention boundaries.

## Core Concepts

- A human principal is TalbyOrgs' representation of an authenticated external user.
- A service principal is TalbyOrgs' representation of a trusted calling service used for governed service-to-service operations.
- An organization is the top-level tenant boundary. Organizations are either personal or non-personal.
- A membership represents a human principal's organizational relationship. Membership kind and role assignment are separate concepts.
- A project is the only child scope under an organization in V1.
- A permission definition is a globally stable capability identifier.
- A role definition is a named bundle of permission definitions.
- A role assignment grants a role to a principal at organization or project scope.
- Ownership is an organization relationship with implicit full authority across the organization and its projects.

## Product Principles

- Deny by default.
- Keep authentication external and authorization internal.
- Prefer explicit relationships over implied access, except for deliberate owner override semantics.
- Keep authoritative writes auditable and rebuild operational state through projections.
- Keep personal data removable even when authorization state is durable.
- Favor simple, governed integration contracts over many overlapping protocol surfaces.

## User Stories

1. As a newly authenticated user, I want TalbyOrgs to materialize my Talby identity automatically, so that I can exist in the system without manual provisioning.
2. As a newly authenticated user, I want TalbyOrgs to create my personal organization automatically, so that I always have a stable home tenant.
3. As a user, I want my personal organization to contain exactly one identity membership for me, so that the relationship between my account and my home tenant is deterministic.
4. As a user, I want identity membership to imply owner authority in my personal organization, so that I can fully administer my home tenant without extra setup.
5. As a user who was never invited to any shared organization, I want to be onboarded successfully anyway, so that platform access does not depend on prior tenant membership.
6. As an invited user, I want my invitation-derived access to resolve when I authenticate, so that onboarding into shared organizations is predictable.
7. As an organization creator, I want a newly created non-personal organization to start with me as its only owner, so that bootstrap ownership is unambiguous.
8. As an organization owner, I want to add other owners after creation, so that administration can be delegated safely.
9. As an organization owner, I want to add regular members without granting them implicit project access, so that visibility remains deliberate.
10. As an organization owner, I want membership kind and role assignment to be separate, so that relationship status and access level can evolve independently.
11. As an organization owner, I want owners to retain effective authority even if explicit role assignments are missing, so that the tenant is recoverable.
12. As an organization owner, I want project access for non-owners to be explicit, so that project boundaries remain understandable.
13. As an organization owner, I want projects to belong to exactly one organization, so that authorization scope is clear.
14. As an organization owner, I want built-in roles to be stable and immutable, so that I can trust their documented behavior.
15. As an organization owner, I want to create custom roles from the global permission catalog, so that my organization can tailor access without inventing new permission semantics.
16. As an organization owner, I want custom roles to be limited to globally registered permissions, so that permission meaning stays consistent across the platform.
17. As an organization owner, I want role assignments to be scoped to an organization or project, so that access maps cleanly to the resource boundary.
18. As an organization owner, I want ownership removal to be validated, so that an organization cannot accidentally become ownerless.
19. As a regular member, I want my access to be determined by explicit memberships and assignments, so that I can understand why I can or cannot perform an action.
20. As a product team, I want my service to register permissions in its own namespace, so that TalbyOrgs can manage access to my service's capabilities.
21. As a product team, I want permission registration to be append-oriented and auditable, so that permission history is governable.
22. As a platform operator, I want only pre-registered services to perform privileged service-to-service operations, so that sensitive integration points stay governed.
23. As a platform operator, I want TalbyOrgs to validate issuer and audience trust for service principals, so that privileged calls are not accepted from untrusted identities.
24. As an integrating service, I want to ask whether a principal has a permission in an organization or project, so that I can enforce access in my own request pipeline.
25. As an integrating service, I want a fast allow-or-deny authorization response, so that authorization checks can fit into latency-sensitive paths.
26. As an integrating service, I want an optional explanation mode, so that I can debug denials or expose safe internal diagnostics.
27. As an operator, I want authorization decisions to be served from projections rather than event replay, so that read latency remains operationally predictable.
28. As an operator, I want explicit idempotency support on external writes, so that retries do not duplicate organizations, memberships, invitations, role assignments, or permissions.
29. As an operator, I want duplicate-intent checks inside aggregates where practical, so that accidental replays are contained even when clients behave poorly.
30. As an operator, I want all domain changes to emit events with correlation metadata, so that investigations and reconciliation are possible.
31. As a privacy-conscious operator, I want personal profile fields stored outside the immutable ledger, so that retention and erasure workflows remain feasible.
32. As a security stakeholder, I want every API to be protected by default unless explicitly opened, so that accidental exposure is minimized.
33. As a platform operator, I want OpenTelemetry logs, traces, and metrics around critical flows, so that distributed failures and auth incidents are diagnosable.
34. As a developer integrating with TalbyOrgs, I want contract behavior around validation, authentication failure, authorization failure, and idempotent retries to be consistent, so that clients are easy to implement correctly.
35. As a platform team, I want the V1 system to stay disciplined about its scope, so that it remains a reliable control plane rather than an ad hoc identity product.

## Functional Requirements

### Identity and Principal Materialization

- TalbyOrgs shall treat external identity providers as authoritative for authentication and upstream identity claims.
- TalbyOrgs shall materialize exactly one Talby human principal for each authenticated external identity in V1.
- TalbyOrgs shall not perform cross-provider identity linking in V1.
- TalbyOrgs shall treat email addresses and similar contact attributes as mutable profile data rather than stable identity keys.
- TalbyOrgs shall keep privacy-sensitive profile material outside the immutable event ledger.

### Personal Organizations

- TalbyOrgs shall create a personal organization for every authenticated human principal.
- Each personal organization shall have exactly one identity membership.
- Identity membership shall exist only in personal organizations.
- Identity membership shall be non-transferable.
- Identity membership shall imply ownership authority for the personal organization.

### Organizations, Memberships, Invitations, and Projects

- Non-personal organizations shall be created with exactly one owner in V1: the creating principal.
- Additional ownership memberships and regular memberships shall be created after organization bootstrap.
- Membership kinds shall be limited to Identity, Ownership, and Regular.
- Invitations shall be contact-based in V1 and shall resolve to an authenticated identity at acceptance time.
- Invitation acceptance shall not suppress or replace personal-organization creation.
- Organizations shall never become ownerless through supported write operations.
- Projects shall belong to exactly one organization.
- Project transfer between organizations shall not be supported in V1.
- Non-owner project access shall require explicit role assignment or equivalent explicit access state.

### Permissions, Roles, and Assignments

- Permission definitions shall be global and not tenant-specific.
- TalbyOrgs shall provide built-in permission definitions.
- Trusted pre-registered services shall be able to register additional global permission definitions within owned namespaces.
- Built-in roles shall be immutable in place.
- Organizations shall be able to create custom roles using only permission definitions from the global catalog.
- Role assignments shall support organization scope and project scope only.
- Authorization shall use scoped RBAC only in V1 and shall not include conditional policy evaluation.

### Authorization Queries

- TalbyOrgs shall answer authorization questions using principal, permission, organization scope, and optional project scope.
- Authorization answers shall be served from eventually consistent projections in V1.
- TalbyOrgs shall provide a fast allow-or-deny response shape suitable for request-path use.
- TalbyOrgs may provide an optional explanation mode for internal and debugging scenarios.
- Explanation output shall be limited to safe details such as matched ownership authority, matched assignments, matched permissions, or denial reason categories.
- Client services shall remain responsible for using TalbyOrgs decisions to enforce or reject their own requests.

### Service Registration and Privileged Integration

- Privileged service-to-service operations shall require a pre-registered service identity.
- TalbyOrgs shall validate calling service identity against trusted issuer and audience configuration before accepting privileged operations.
- Services shall be able to register permissions only within namespaces they own.
- Permission registration shall be auditable and idempotent.

### Data, Audit, and Reliability

- All authoritative model changes shall be persisted through an event-sourced write model.
- Events shall include durable identifiers, timestamps, actor context, and correlation metadata needed for audit and debugging.
- Event payloads shall avoid removable personal data whenever a reference can be used instead.
- Projections shall be treated as rebuildable operational read models.
- External write APIs shall support explicit idempotency keys.
- Aggregates shall protect against duplicate intent where practical.
- Every API shall be protected by default unless explicitly exempted for health or bootstrap scenarios.

## Major Workflows

### First Human Sign-In

1. External identity provider authenticates the user.
2. TalbyOrgs materializes or resolves the matching human principal.
3. TalbyOrgs creates the user's personal organization if it does not already exist.
4. TalbyOrgs creates the identity membership for that personal organization.
5. TalbyOrgs applies any invitation acceptance logic without skipping personal-organization bootstrap.
6. Projection state becomes queryable for user, organization, and membership reads.

### Non-Personal Organization Creation

1. Authenticated human principal submits organization creation.
2. TalbyOrgs creates the organization as non-personal.
3. TalbyOrgs grants the creating principal the initial ownership relationship.
4. Projection state exposes the organization and ownership summary for operational reads.

### Authorization Decision Evaluation

1. Calling client submits principal, permission, organization, and optional project.
2. TalbyOrgs validates that the principal and referenced scope exist in projection state.
3. TalbyOrgs checks for effective ownership authority in the organization.
4. If ownership does not apply, TalbyOrgs resolves effective role assignments for the requested scope.
5. TalbyOrgs determines whether any effective assignment includes the requested permission.
6. TalbyOrgs returns allow or deny, with optional explanation details when requested.

### Service Permission Registration

1. Calling service authenticates with a trusted issuer.
2. TalbyOrgs validates the service registration, issuer, audience, and namespace ownership.
3. TalbyOrgs accepts append-oriented permission registration within owned namespaces only.
4. Registered permissions become available to the global permission catalog and custom-role composition flows.

## Implementation Decisions

- TalbyOrgs V1 will be a shared internal control-plane service rather than a per-customer deployment unit.
- The write model will be organized around bounded contexts for principal registry, organization and membership management, authorization catalog and assignments, and service registration.
- The authoritative write path will use aggregates that enforce invariants and emit audit-safe domain events.
- The read path will use disposable projections for principal summary, organization summary, memberships, projects, permission catalog, role definitions, role assignments, service registrations, invitations, operator audit, and effective authorization state.
- Personal organizations and identity memberships are first-class domain concepts rather than onboarding conveniences layered outside the model.
- Ownership is modeled as an organization relationship with implicit full authority and is not represented purely as a normal RBAC role bundle.
- Membership kind and role assignment remain separate so organization relationship and access rights can evolve independently.
- Organizations are the top-level tenant boundary, and projects are the only child scope supported in V1.
- Permission definitions are global so the system can provide one consistent authorization vocabulary across all tenants and products.
- Service-defined permission registration is governed by service registration and namespace ownership rather than open self-service registration.
- Built-in roles are immutable; custom roles are organization-owned compositions of global permissions.
- Authorization answers are generated from projection-backed effective access state instead of request-time event replay.
- PostgreSQL is the initial persistence substrate for the event ledger, projections, and removable profile storage, with explicit logical separation between those storage responsibilities.
- REST is the primary V1 API surface for mutations and core operational queries.
- Additional protocols may be introduced only for targeted notification, streaming, or read-oriented scenarios and must not become parallel write surfaces by default.
- External mutations require idempotency-key support, and internal aggregate logic should reject duplicate intent where practical.
- Domain events must carry identifiers and correlation metadata sufficient for traceability, reconciliation, and operator investigations.
- OpenTelemetry is the standard instrumentation model for traces, metrics, and structured logs.
- Formal public API versioning is deferred in V1, but this is a known follow-up risk and must be revisited before broad external adoption.

## Testing Decisions

- Prefer behavior-first tests that validate externally visible system behavior rather than framework internals or private implementation details.
- Test aggregate behavior as command-to-event outcomes plus invariant enforcement, especially around personal-organization bootstrap, uniqueness, ownership preservation, duplicate-intent handling, and namespace governance.
- Test projection behavior by replaying representative event sequences into projections and asserting the operational query state and effective authorization state produced.
- Test authorization behavior as observable allow, deny, and explanation outcomes for owner override, organization-scope assignments, project-scope assignments, invalid scopes, and missing assignments.
- Test REST contracts for success paths, validation failures, authentication failures, authorization failures, conflict handling, and idempotent retry semantics.
- Test end-to-end flows for first sign-in, personal-organization creation, invitation acceptance, non-personal organization creation, membership changes, project access assignment, permission registration by trusted services, and authorization queries used by integrating services.
- Test privacy boundaries by asserting that mutable personal profile data is stored by reference outside the immutable event ledger.
- Test observability behavior around critical workflows so traces, logs, and metrics are emitted with enough structure for operator use.
- Avoid brittle tests that overfit ORM behavior, transport-library details, or internal projection implementation mechanics.

## Release Criteria

- First successful sign-in reliably materializes a principal and personal organization.
- Organization, membership, project, role, and permission workflows emit correct domain events and maintain invariants.
- Projection-backed operational queries return correct organization, membership, and authorization state.
- Authorization decisions match ownership and scoped RBAC rules.
- Trusted services can register permissions only within owned namespaces.
- Retry behavior is deterministic and does not create duplicate domain state for supported idempotent operations.
- Privacy-sensitive profile data is excluded from immutable event payloads.
- Operators can observe critical flows, projection lag, and authorization behavior through standard telemetry.

## Out of Scope

- Conditional authorization policies, policy expressions, and policy DSLs
- Resource-instance authorization beyond organization and project scope
- Cross-organization project sharing or project transfer
- Generalized hierarchical scope trees
- Tenant-specific permission definitions
- Dynamic service onboarding without prior registration
- Service principals acting as organization memberships
- Strong-consistency authorization reads or revocation-safe reads in V1
- Full multi-protocol parity for writes across REST and other transports
- Public-facing audit product features
- Local profile editing that overrides identity-provider-managed attributes
- Credential management for humans or services
- Compliance automation beyond audit-safe events and removable sensitive storage posture

## Further Notes

- Eventually consistent authorization creates short revocation windows that may be acceptable in V1 but will need continued evaluation for higher-risk use cases.
- Owner override semantics simplify recovery and administration, but they require careful documentation so product teams do not mistake ownership for a normal role assignment.
- Using PostgreSQL for the ledger, projections, and removable profile storage is acceptable in V1 only if the logical boundaries between those storage concerns remain explicit.
- Permission registration governance will weaken quickly if service onboarding and namespace ownership discipline are not enforced operationally.
- Formal API and event schema versioning remain unresolved follow-up areas and should be addressed before TalbyOrgs is treated as a broad shared platform dependency.
