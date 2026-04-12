# TalbyOrgs V1 Product Requirements Document

## Problem Statement

TalbyOrgs is an internal control-plane service for managing organizational structure and authorization across products. It owns organizations, memberships, projects, roles, permissions, service registrations, and authorization decisions, while delegating authentication to external identity providers.

The current problem is not basic user CRUD. The platform must provide a stable multi-tenant backbone that other services can depend on for organizational boundaries, access-control assignments, permission registration, and authorization questions. It must remain auditable, observable, horizontally scalable, and safe to evolve without becoming an ad hoc identity system or a fragile set of unrelated APIs.

V1 must prove that TalbyOrgs can act as a reliable shared registry and authorization service with clear boundaries:

- external IdPs authenticate humans and services
- TalbyOrgs owns organizational and authorization state
- authorization decisions are answered from Talby projections
- client services remain responsible for enforcing Talby decisions in their own request pipelines

## Solution

TalbyOrgs V1 will provide a shared internal service that:

- materializes authenticated users into Talby principals
- automatically creates a personal organization for every user
- manages non-personal organizations, memberships, projects, roles, permissions, and service identities
- supports built-in permissions and service-registered global permissions
- supports built-in roles and tenant-defined custom roles
- answers authorization questions for org-scoped and project-scoped permissions
- emits all domain changes through an event-sourced write model backed by PostgreSQL
- serves operational queries from eventually consistent projections
- keeps personally sensitive data outside the immutable event ledger

V1 will use REST as the primary API surface. Additional protocols may exist for targeted streaming, notifications, or efficient service integrations, but they are not independent primary mutation surfaces in V1.

## Goals

- Establish TalbyOrgs as the system of record for organizations, memberships, projects, role assignments, and permission registrations.
- Support human principals authenticated by external IdPs without Talby owning credential management.
- Create a deterministic onboarding flow where every human principal gets a personal organization with an identity membership.
- Provide org-scoped and project-scoped RBAC with clear owner semantics.
- Allow trusted pre-registered client services to register global permission definitions for their own namespaces.
- Provide authorization query APIs that return allow or deny and can optionally include explanation details.
- Preserve a durable event ledger for all domain changes while keeping removable sensitive data outside the ledger.
- Instrument the service with OpenTelemetry and operator-grade diagnostics.
- Establish a behavior-first testing strategy for commands, projections, authorization, and protocol contracts.

## Non-Goals

- Acting as a primary authentication system for humans or machines
- Managing passwords, MFA, or credential issuance as a core responsibility
- Exposing public audit-history product features in V1
- Supporting ABAC, policy expressions, or conditional authorization beyond scoped RBAC
- Supporting arbitrary hierarchical resource trees beyond organization and project
- Supporting cross-organization project sharing or project transfer
- Supporting tenant-specific permission definitions
- Supporting dynamic service onboarding without pre-registration
- Providing strong-consistency authorization reads or revocation-safe reads in V1
- Offering broad multi-protocol write APIs across REST, gRPC, GraphQL, and realtime endpoints
- Supporting editable local user profiles that override IdP-owned identity attributes

## Users and Stakeholders

1. Platform operators who run and monitor TalbyOrgs.
2. Product teams integrating their services with TalbyOrgs for permissions and authorization.
3. Organization owners who manage membership, ownership, projects, and role assignments.
4. Organization members who receive access to organizations and projects.
5. Internal developers who build automation and service-to-service integrations on top of TalbyOrgs.

## Core User Stories

1. As a newly authenticated user, I want TalbyOrgs to create my personal organization automatically, so that I always have a stable home tenant.
2. As a user, I want my personal organization to contain an identity membership that implies owner authority, so that my home tenant is fully controllable by me.
3. As an organization creator, I want a newly created organization to start with me as the only owner, so that bootstrap ownership is deterministic.
4. As an organization owner, I want to add ownership and regular memberships after creation, so that I can delegate administration and collaboration deliberately.
5. As an invited user, I want authentication to materialize my Talby identity and apply my invitation-derived membership, so that onboarding is predictable.
6. As a user who was not invited anywhere, I want to exist in Talby anyway through my personal organization, so that platform onboarding does not depend on prior membership.
7. As an organization owner, I want membership kinds and role assignments to be separate, so that organizational relationship and access can evolve independently.
8. As an owner, I want owners to have full effective authority within their organization and projects, so that recovery and administration do not depend on additional bootstrap roles.
9. As a regular member, I want project access to be explicit, so that organization membership does not silently grant broad visibility.
10. As an organization admin, I want projects to belong to exactly one organization, so that authorization boundaries remain clear.
11. As an organization admin, I want built-in roles to remain stable and immutable, so that I can rely on their documented meaning.
12. As an organization admin, I want to create custom roles from the global permission catalog, so that my organization can tailor access without inventing new permission semantics.
13. As a product team, I want my service to register global permissions in my own namespace, so that TalbyOrgs can manage access to my service operations.
14. As a platform operator, I want services to be pre-registered and validated before Talby accepts privileged service-to-service requests, so that permission registration is governed.
15. As an integrating service, I want TalbyOrgs to answer authorization questions for a principal, permission, and scope, so that I can enforce access consistently.
16. As an integrating service, I want optional authorization explanations, so that I can debug or surface safe denial reasons when needed.
17. As a privacy-conscious operator, I want personally sensitive information to live outside the immutable event ledger, so that retention and erasure workflows remain possible.
18. As a platform operator, I want event-sourced domain changes and projection-backed queries, so that TalbyOrgs is both auditable and operationally efficient.
19. As an API client, I want idempotent mutation behavior, so that retries do not accidentally duplicate organizations, memberships, invitations, or permission registrations.
20. As an operator, I want OpenTelemetry-based logs, traces, and metrics, so that distributed debugging and security investigations are practical.

## Functional Requirements

### Identity and Principal Materialization

- TalbyOrgs shall treat external IdPs as authoritative for authentication and identity claims.
- TalbyOrgs shall materialize one Talby human principal per authenticated external identity.
- TalbyOrgs shall not perform cross-provider identity linking in V1.
- TalbyOrgs shall treat email and similar contact fields as mutable attributes rather than stable identity.

### Personal Organizations

- TalbyOrgs shall create a personal organization for every authenticated human principal.
- Each personal organization shall have exactly one identity membership.
- Identity membership shall exist only in personal organizations.
- Identity membership shall imply ownership authority for the personal organization.
- Identity membership shall be non-transferable.

### Organizations, Memberships, and Projects

- Non-personal organizations shall be created with exactly one owner in V1: the creator.
- Additional ownership and regular memberships shall be added after organization creation.
- Membership kinds shall be `Identity`, `Ownership`, or `Regular`.
- Projects shall belong to exactly one organization.
- Project transfer between organizations shall not be supported in V1.
- Project access shall be explicit except for owners.

### Roles and Permissions

- Permission definitions shall be global, not tenant-specific.
- TalbyOrgs shall provide built-in permissions.
- Trusted pre-registered client services shall be able to register additional global permissions within their own namespaces.
- Built-in roles shall be immutable.
- Organizations shall be able to create custom roles from the global permission catalog.
- Authorization shall use org scope and project scope only in V1.
- Authorization shall use pure RBAC in V1 with no conditional policy engine.

### Authorization Queries

- TalbyOrgs shall answer authorization questions based on principal, permission, organization scope, and optional project scope.
- Authorization answers shall be served from eventually consistent projections in V1.
- TalbyOrgs shall support a fast allow-or-deny response.
- TalbyOrgs may support an explain mode that returns matched access facts and denial reasons suitable for internal use.
- Client services shall remain responsible for using Talby’s decision to allow or reject their own requests.

### Service Registration and Permission Registration

- Privileged service-to-service operations shall require pre-registered service identities.
- TalbyOrgs shall validate the calling service principal and trusted issuer configuration before accepting privileged operations.
- Services shall be able to register permission definitions only within their own namespaces.
- Permission registration shall be append-oriented and auditable.

### Data, Privacy, and Audit

- All authoritative model updates shall be event-sourced.
- Event payloads shall avoid storing removable personal data.
- Sensitive profile data shall live outside the immutable ledger in removable storage.
- Projections shall support operational queries without requiring event replay on request paths.
- Audit data shall exist in V1 for internal, operator, and compliance use, but shall not be exposed as a general product feature.

### API and Reliability

- REST shall be the principal V1 API surface.
- Additional protocols may be introduced selectively for streaming or realtime needs.
- External write APIs shall support explicit idempotency keys.
- Aggregates shall also protect against duplicate intent where feasible.
- Every API shall be protected by default unless explicitly opened for health or bootstrap needs.

## Implementation Decisions

- TalbyOrgs is a shared internal control-plane service, not a customer-isolated deployment unit in V1.
- Authentication is external; Talby owns authorization and organizational registry state.
- Human principals always exist after first successful authentication, even without invitations.
- Invitations are contact-based in V1 and resolve to stable authenticated identity at acceptance time.
- Membership kind and role assignment are separate concepts.
- Ownership is an organization relationship with implicit full authority; it is not only an RBAC bundle.
- Identity membership is a personal-organization-only concept and implies ownership authority.
- Service principals are used for trusted service-to-service operations; human membership semantics remain separate.
- PostgreSQL is the initial persistence substrate for the event ledger, projections, and removable sensitive storage, with strict logical separation between those responsibilities.
- OpenTelemetry is the standard instrumentation model.
- Formal public API versioning is deferred, but this introduces future migration risk and should be revisited before broad external adoption.

## Milestone Plan

### Milestone 1: Core Domain Backbone

Outcome:
TalbyOrgs can materialize human principals, create personal organizations, create non-personal organizations, manage memberships, and persist core domain changes through an event-sourced write model.

Scope:

- principal materialization from authenticated external identity
- automatic personal organization creation
- organization creation with single initial owner
- membership lifecycle for identity, ownership, and regular memberships
- event store and projection pipeline foundations
- PostgreSQL logical storage separation for ledger, projections, and removable sensitive data
- deny-by-default API foundation

Exit criteria:

- first sign-in reliably creates principal and personal organization
- organization and membership commands emit correct events
- projections answer basic org and membership queries
- sensitive profile data is excluded from immutable event payloads

### Milestone 2: RBAC and Authorization Queries

Outcome:
TalbyOrgs can manage permissions, built-in roles, custom roles, role assignments, projects, and authorization answers for org and project scope.

Scope:

- project lifecycle within one organization
- global permission catalog with built-in permissions
- immutable built-in roles and tenant-defined custom roles
- role assignment lifecycle at org and project scope
- owner override semantics
- authorization query API with optional explanation mode
- eventually consistent authorization projections

Exit criteria:

- project access is explicit except for owners
- authorization decisions match role and ownership state
- explanation responses are available for internal/debug usage

### Milestone 3: Service Integration and Permission Registration

Outcome:
Trusted client services can integrate with TalbyOrgs, register permissions in owned namespaces, and query authorization for their own enforcement pipelines.

Scope:

- service identity model and pre-registration workflow
- trusted issuer validation for service-to-service calls
- permission registration API with namespace governance
- idempotent registration behavior
- low-friction service integration guidance and contracts

Exit criteria:

- only pre-registered services can register permissions
- services cannot escape their namespaces
- registered permissions become available for custom-role composition and authorization decisions

### Milestone 4: Operational Hardening

Outcome:
TalbyOrgs is observably operable, resilient to retries, and testable as a production control-plane service.

Scope:

- OpenTelemetry logs, traces, and metrics
- idempotency key support on all external write operations
- duplicate-intent checks inside aggregates where practical
- behavior-first automated test suite for commands, projections, authorization, and API contracts
- internal audit views and operator diagnostics

Exit criteria:

- critical workflows have end-to-end test coverage
- projection lag and auth-query behavior are observable
- retry behavior is deterministic and safe

### Milestone 5: Selective Multi-Protocol Expansion

Outcome:
TalbyOrgs adds focused non-REST integrations without turning V1 into a multi-protocol mutation platform.

Scope:

- targeted streaming or realtime notifications
- focused service-to-service protocol enhancements where justified
- read-oriented or notification-oriented protocol additions

Exit criteria:

- added protocols do not duplicate the primary mutation surface indiscriminately
- protocol behavior remains aligned with the same internal application contracts

## Testing Decisions

- Prefer behavior-first tests over broad implementation-detail unit coverage.
- Validate aggregate behavior as command-to-event outcomes plus invariant enforcement.
- Validate projections from event sequences to expected query state.
- Validate authorization as observable allow, deny, and explanation behavior.
- Validate REST contract behavior, including authentication failures, authorization failures, validation errors, and idempotent retries.
- Add end-to-end coverage for first sign-in, personal-org creation, invitation acceptance, project access assignment, and permission registration by trusted services.
- Avoid brittle tests that overfit framework internals.

## Risks and Follow-Up Concerns

- Deferring formal API versioning increases future migration cost, especially around event and client contract evolution.
- Eventually consistent authorization answers create short revocation windows that may become unacceptable for some use cases later.
- Owner override semantics simplify V1 but will need careful documentation to avoid confusion around explicit roles.
- Using PostgreSQL for all three storage responsibilities is reasonable in V1, but operational boundaries must remain explicit to avoid data-shape bleed.
- Permission registration governance will become fragile if namespace ownership or service onboarding discipline weakens.

## Out of Scope

- conditional authorization policies and policy DSLs
- external resource-instance semantics in authorization queries
- public-facing audit product features
- cross-org project sharing or project transfer
- generalized hierarchical scope trees
- dynamic service onboarding
- tenant-specific permission definitions
- service principals as memberships
- strong consistency authorization reads
- full multi-protocol write parity
- local profile editing that overrides IdP-owned data
- credential issuance for humans or services
- compliance automation beyond soft-delete posture and removable sensitive storage
