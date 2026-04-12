# TalbyOrgs V1 Domain Model and Aggregate Event Catalog

## Domain Overview

TalbyOrgs is a shared internal control-plane service with an event-sourced write model. The domain is centered on organizational structure, access-control assignments, permission registration, and authorization decisions.

V1 domain rules:

- authentication is external
- Talby materializes principals and owns authorization state
- every authenticated human gets a personal organization
- membership kind and role assignment are separate concepts
- authorization is scoped RBAC only
- all authoritative writes emit domain events
- personally sensitive data is kept outside the immutable event ledger

## Bounded Contexts

### Principal Registry

Owns:

- Talby human principals
- service principals
- external identity references for authenticated humans
- soft-delete and disablement state

Does not own:

- credentials
- password or MFA lifecycle
- cross-provider identity linking logic

### Organization and Memberships

Owns:

- organizations
- personal-organization invariants
- membership lifecycle
- ownership invariants
- project parentage

### Authorization Catalog and Assignments

Owns:

- global permission definitions
- built-in role definitions
- custom tenant role definitions
- role assignments at org and project scope
- authorization projections used for decision answers

### Service Registration

Owns:

- pre-registered client services
- trusted issuer configuration
- namespace ownership for permission registration

## Core Entities and Concepts

### Human Principal

Represents one authenticated human identity as materialized by Talby from an external IdP.

Key properties:

- principal ID
- external subject reference
- external issuer reference
- status
- personal organization ID
- removable profile reference

Invariants:

- one Talby human principal per authenticated external identity in V1
- each human principal has exactly one personal organization

### Service Principal

Represents a non-human calling service trusted to perform governed service-to-service operations.

Key properties:

- service principal ID
- service ID
- trusted issuer configuration reference
- allowed namespace set
- status

Invariants:

- service principals are pre-registered before privileged access
- service principals are not human memberships in V1

### Organization

Represents a tenant boundary. There are two kinds in V1: personal and non-personal.

Key properties:

- organization ID
- organization kind
- display metadata reference
- status
- creator principal ID

Invariants:

- personal organizations are anchored to exactly one human principal
- non-personal organizations are created with exactly one initial owner in V1
- an organization must always have at least one effective owner after bootstrap rules are applied

### Membership

Represents a human principal’s organizational relationship.

Membership kinds:

- `Identity`
- `Ownership`
- `Regular`

Key properties:

- membership ID
- organization ID
- principal ID
- membership kind
- status

Invariants:

- identity membership exists only in personal organizations
- identity membership implies owner authority for the personal organization
- ownership conveys implicit full authority in the organization and its projects
- regular membership conveys no implicit project access

### Project

Represents the only child scope type under an organization in V1.

Key properties:

- project ID
- parent organization ID
- status
- display metadata reference

Invariants:

- project belongs to exactly one organization
- project transfer between organizations is out of scope in V1

### Permission Definition

Represents a globally stable capability identifier.

Key properties:

- permission ID
- namespace
- owning service or system owner
- scope applicability
- display metadata
- lifecycle status

Invariants:

- permissions are global, not tenant-specific
- Talby built-in permissions and service-defined permissions share the same global catalog
- service-defined permissions must remain inside the service’s owned namespace

### Role Definition

Represents a named permission bundle.

Kinds:

- built-in role
- custom tenant role

Key properties:

- role definition ID
- owner type
- organization ID for custom roles
- allowed scope type
- included permissions
- lifecycle status

Invariants:

- built-in roles are immutable in place
- custom roles can only use global permissions

### Role Assignment

Represents granted access for a principal within a scope.

Key properties:

- role assignment ID
- assignee type
- assignee ID
- role definition ID
- scope type
- scope ID
- status

Invariants:

- human principals and service principals can receive role assignments
- regular project access is explicit except for owners

### Service Registration

Represents governance state for a client service allowed to perform privileged integration operations.

Key properties:

- service ID
- trusted issuer list
- accepted audiences
- owned namespaces
- allowed operations
- status

Invariants:

- only pre-registered services can perform privileged service-to-service operations
- a service can register permissions only in namespaces it owns

### Invitation

Represents pre-authenticated access intent.

Key properties:

- invitation ID
- contact identifier
- target organization ID
- intended membership kind
- intended role assignments
- expiry status

Invariants:

- invitations are contact-based in V1
- invitation acceptance resolves against authenticated identity at materialization time
- invite acceptance does not suppress personal-organization creation

## Aggregate Design

The write model should use aggregates that protect business invariants and produce audit-safe event streams.

Recommended V1 aggregates:

1. HumanPrincipalAggregate
2. ServicePrincipalAggregate
3. OrganizationAggregate
4. MembershipAggregate
5. ProjectAggregate
6. PermissionCatalogAggregate or PermissionDefinitionAggregate
7. RoleDefinitionAggregate
8. RoleAssignmentAggregate
9. ServiceRegistrationAggregate
10. InvitationAggregate

### HumanPrincipalAggregate

Responsibilities:

- materialize human principal from authenticated identity
- manage disable or soft-delete lifecycle
- anchor personal organization relationship

Key invariants:

- principal is unique for the external identity seen by Talby
- principal owns exactly one personal organization reference

### ServicePrincipalAggregate

Responsibilities:

- manage machine principal lifecycle for privileged service calls
- bind service identity to registered trust configuration

### OrganizationAggregate

Responsibilities:

- create personal and non-personal organizations
- enforce organization kind invariants
- enforce initial ownership bootstrap rules

### MembershipAggregate

Responsibilities:

- create, change, suspend, and remove memberships
- enforce identity-membership and ownership rules

### ProjectAggregate

Responsibilities:

- create and manage projects within one organization
- enforce single-parent org rule

### PermissionDefinitionAggregate

Responsibilities:

- register built-in or service-defined permissions
- enforce namespace ownership
- handle deprecation and lifecycle changes

### RoleDefinitionAggregate

Responsibilities:

- manage built-in and custom role composition
- enforce immutability rules for built-ins

### RoleAssignmentAggregate

Responsibilities:

- assign and revoke roles at org or project scope
- enforce assignee and scope validity

### ServiceRegistrationAggregate

Responsibilities:

- pre-register services
- manage trusted issuer settings, namespace ownership, and status

### InvitationAggregate

Responsibilities:

- issue, revoke, expire, and accept invitations
- record intended membership and initial role assignment intents

## Aggregate Event Catalog

Events should contain durable IDs, security facts, timestamps, actor context, correlation metadata, and references to removable sensitive data where needed. Events should not store unnecessary PII.

### HumanPrincipalAggregate Events

- `HumanPrincipalMaterialized`
- `HumanPrincipalDisabled`
- `HumanPrincipalSoftDeleted`
- `HumanPrincipalReactivated`
- `HumanPrincipalProfileReferenceUpdated`
- `HumanPrincipalPersonalOrganizationLinked`

### ServicePrincipalAggregate Events

- `ServicePrincipalCreated`
- `ServicePrincipalIssuerBound`
- `ServicePrincipalAudienceUpdated`
- `ServicePrincipalSuspended`
- `ServicePrincipalReactivated`

### OrganizationAggregate Events

- `PersonalOrganizationCreated`
- `OrganizationCreated`
- `OrganizationRenamed`
- `OrganizationSuspended`
- `OrganizationReactivated`
- `OrganizationSoftDeleted`

### MembershipAggregate Events

- `IdentityMembershipCreated`
- `OwnershipMembershipGranted`
- `RegularMembershipGranted`
- `MembershipKindChanged`
- `MembershipSuspended`
- `MembershipReactivated`
- `MembershipRemoved`

Notes:

- `MembershipKindChanged` should likely exclude transitions to or from `Identity` unless explicitly intended by model rules. In practice, separate grant and removal events may be clearer.
- ownership-removal commands must be validated so an organization does not become ownerless.

### ProjectAggregate Events

- `ProjectCreated`
- `ProjectRenamed`
- `ProjectArchived`
- `ProjectReactivated`
- `ProjectDeleted`

### PermissionDefinitionAggregate Events

- `BuiltInPermissionRegistered`
- `ServicePermissionRegistered`
- `PermissionMetadataUpdated`
- `PermissionDeprecated`
- `PermissionReactivated`

Notes:

- destructive deletion of permission definitions should be avoided in V1; deprecation is safer.

### RoleDefinitionAggregate Events

- `BuiltInRoleRegistered`
- `CustomRoleCreated`
- `CustomRoleRenamed`
- `CustomRolePermissionsReplaced`
- `CustomRoleArchived`
- `CustomRoleReactivated`

Notes:

- built-in role mutation events should be exceptional and treated as platform-governed changes.

### RoleAssignmentAggregate Events

- `RoleAssigned`
- `RoleRevoked`
- `RoleAssignmentSuspended`
- `RoleAssignmentReactivated`

### ServiceRegistrationAggregate Events

- `ServiceRegistered`
- `ServiceIssuerAdded`
- `ServiceIssuerRemoved`
- `ServiceAudienceAdded`
- `ServiceAudienceRemoved`
- `ServiceNamespaceGranted`
- `ServiceNamespaceRevoked`
- `ServiceRegistrationSuspended`
- `ServiceRegistrationReactivated`

### InvitationAggregate Events

- `InvitationIssued`
- `InvitationResent`
- `InvitationRevoked`
- `InvitationExpired`
- `InvitationAccepted`

## Event Metadata Requirements

Every domain event should carry or be envelope-associated with:

- event ID
- aggregate ID
- aggregate version
- event type
- occurred-at timestamp
- actor type and actor ID
- correlation ID
- causation ID
- organization ID when applicable
- project ID when applicable
- idempotency key reference when applicable

## Projection Model

Projection families needed in V1:

- principal summary projection
- organization summary projection
- membership projection
- project projection
- global permission catalog projection
- role definition projection
- role assignment projection
- authorization decision projection or effective-access projection
- service registration projection
- invitation projection
- operator audit projection

Guidelines:

- projections are disposable and rebuildable
- authorization responses must come from projections, not direct event replay
- sensitive profile data should be joined by reference from removable storage rather than denormalized broadly

## Authorization Decision Model

V1 authorization input:

- principal ID
- permission ID
- organization ID
- optional project ID

V1 authorization evaluation order:

1. validate principal and scope existence in projection state
2. if principal holds effective ownership authority in the organization, allow
3. otherwise resolve effective role assignments for the requested scope
4. evaluate whether the requested permission is included
5. return allow or deny and optional explanation details

V1 explanation payload may include:

- resolved principal
- resolved scope
- matched ownership shortcut or matched role assignments
- matched permissions
- denial reason such as missing role, missing project assignment, or invalid scope

## Idempotency and Duplicate Protection

V1 external mutation protection should combine:

- explicit API idempotency keys
- aggregate duplicate-intent detection where practical
- optimistic concurrency checks

This is particularly important for:

- organization creation
- invitation issuance
- membership creation
- role assignment
- permission registration
- project creation

## Privacy and Retention Boundaries

Do store in the event ledger:

- stable IDs
- scope IDs
- actor IDs
- security facts
- lifecycle status changes
- references to removable profile state

Do not casually store in the event ledger:

- mutable personal profile fields
- removable contact data when a reference can be used instead
- broad claim dumps from upstream IdPs

Use removable storage for:

- display names
- avatars
- mutable contact information where removal is required
- other privacy-sensitive profile material

## Open Questions for Later Versions

- formal API and event schema versioning strategy
- stronger consistency modes for authorization reads
- public audit feature design
- richer policy or ABAC support
- external resource-instance authorization context
- service-principal direct access semantics in more detail
- generalized hierarchy beyond projects
