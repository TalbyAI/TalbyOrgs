# Ubiquitous Language

## Identity and Actors

| Term                  | Definition                                                                                                                                   | Aliases to avoid                             |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| **TalbyOrgs**         | TalbyOrgs is the internal control-plane service that owns organization and authorization state for Talby products.                           | org service, tenant service, identity system |
| **External Identity** | An External Identity is the upstream human or service identity authenticated by a trusted external identity provider.                        | user account, login, principal               |
| **Human Principal**   | A Human Principal is TalbyOrgs' materialized representation of one authenticated human external identity.                                    | user, account, identity                      |
| **Service Principal** | A Service Principal is TalbyOrgs' materialized representation of a trusted non-human caller used for governed service-to-service operations. | app, service account, integration            |
| **Principal**         | A Principal is any actor that can be evaluated for authorization, currently either a Human Principal or a Service Principal.                 | subject, identity                            |
| **Client Service**    | A Client Service is an internal Talby service that integrates with TalbyOrgs for permission registration or authorization checks.            | app, caller, consumer                        |

## Organization and Access Model

| Term                          | Definition                                                                                                                                        | Aliases to avoid                        |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **Organization**              | An Organization is the top-level tenant boundary that contains memberships, projects, and organization-scoped access state.                       | tenant, workspace, account              |
| **Personal Organization**     | A Personal Organization is the unique organization anchored to exactly one Human Principal and created automatically on first sign-in.            | home tenant, user org, personal tenant  |
| **Non-Personal Organization** | A Non-Personal Organization is a shared organization created explicitly for collaboration among multiple principals.                              | team org, shared tenant                 |
| **Membership**                | A Membership is a Human Principal's organizational relationship and does not by itself define RBAC permissions.                                   | access, seat, enrollment                |
| **Identity Membership**       | An Identity Membership is the non-transferable membership kind that exists only in a Personal Organization and implies ownership authority there. | personal membership, default membership |
| **Ownership Membership**      | An Ownership Membership is the membership kind that establishes organization ownership as a relationship, not as a normal role.                   | owner role, admin role                  |
| **Regular Membership**        | A Regular Membership is the membership kind that establishes organization affiliation without implicit project access.                            | member role, basic membership           |
| **Ownership Authority**       | Ownership Authority is the effective full authority that owners have across an organization and all of its projects.                              | admin permission, owner role            |
| **Project**                   | A Project is the only child scope under an Organization in V1 and belongs to exactly one Organization.                                            | sub-tenant, workspace, resource group   |
| **Scope**                     | A Scope is the resource boundary at which access is evaluated, limited in V1 to Organization Scope or Project Scope.                              | level, boundary, context                |
| **Organization Scope**        | Organization Scope is the access boundary of an entire Organization.                                                                              | tenant scope, org level                 |
| **Project Scope**             | Project Scope is the access boundary of one Project within an Organization.                                                                       | child scope, project level              |

## Authorization and Governance

| Term                       | Definition                                                                                                                                                 | Aliases to avoid                    |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| **Permission Definition**  | A Permission Definition is a globally stable capability identifier in the shared permission catalog.                                                       | permission, claim, action           |
| **Permission Catalog**     | The Permission Catalog is the global set of built-in and service-registered Permission Definitions available to all organizations.                         | permission list, tenant permissions |
| **Namespace**              | A Namespace is the governed ownership boundary within which a service may register Permission Definitions.                                                 | prefix, category                    |
| **Role Definition**        | A Role Definition is a named bundle of Permission Definitions that can be granted at an allowed scope.                                                     | role, profile                       |
| **Built-In Role**          | A Built-In Role is a platform-governed immutable Role Definition supplied by TalbyOrgs.                                                                    | system role, default role           |
| **Custom Role**            | A Custom Role is an organization-owned Role Definition composed only from Permission Definitions in the global catalog.                                    | tenant role, local role             |
| **Role Assignment**        | A Role Assignment is the grant of a Role Definition to a Principal at Organization Scope or Project Scope.                                                 | membership, access grant, role      |
| **Authorization Decision** | An Authorization Decision is TalbyOrgs' allow-or-deny answer for whether a Principal has a Permission Definition at a requested Scope.                     | access check, auth result           |
| **Explanation Mode**       | Explanation Mode is the optional diagnostic form of an Authorization Decision that reports safe reasoning details for an allow or deny result.             | debug auth, verbose auth            |
| **Invitation**             | An Invitation is pre-authenticated access intent that resolves to a Human Principal when the invited person authenticates.                                 | invite, pending membership          |
| **Service Registration**   | A Service Registration is the governance record that defines which Client Service identities, audiences, namespaces, and operations are trusted.           | service config, client registration |
| **Projection**             | A Projection is a rebuildable read model used to answer operational queries and authorization decisions without replaying events on the request path.      | read model, cached state            |
| **Event Ledger**           | The Event Ledger is the immutable store of authoritative domain events that records durable state changes without storing removable profile data casually. | event store, audit log              |
| **Idempotency Key**        | An Idempotency Key is the client-supplied identifier used to make a retried external mutation resolve as one intent instead of duplicate state.            | retry token, request key            |

## Relationships

- A **Human Principal** is materialized from exactly one **External Identity** in V1.
- A **Human Principal** has exactly one **Personal Organization**.
- A **Personal Organization** has exactly one **Identity Membership**.
- An **Organization** has one or more **Memberships**.
- An **Organization** has zero or more **Projects**.
- A **Project** belongs to exactly one **Organization**.
- A **Membership** belongs to exactly one **Organization** and exactly one **Human Principal**.
- An **Ownership Membership** grants **Ownership Authority** across exactly one **Organization** and all of its **Projects**.
- A **Role Definition** contains one or more **Permission Definitions**.
- A **Role Assignment** grants exactly one **Role Definition** to exactly one **Principal** at exactly one **Scope**.
- A **Custom Role** belongs to exactly one **Organization**.
- A **Permission Definition** belongs to the global **Permission Catalog**.
- A **Service Registration** governs one **Client Service** and one or more owned **Namespaces**.
- An **Authorization Decision** is evaluated from **Projection** state for exactly one **Principal**, one **Permission Definition**, and one requested **Scope**.
- The **Event Ledger** produces the domain events from which **Projections** are rebuilt.

## Example dialogue

> **Dev:** "If a regular member belongs to an organization, do they automatically get project access?"
> **Domain expert:** "No. A **Regular Membership** only establishes the organizational relationship; project access requires an explicit **Role Assignment** at **Project Scope** unless the principal has **Ownership Authority**."
> **Dev:** "Should we model an owner as a built-in role so authorization stays uniform?"
> **Domain expert:** "No. Use **Ownership Membership** for the relationship and **Ownership Authority** for the effective access, because ownership is not a normal **Role Definition** in this domain."
> **Dev:** "When a service adds a new capability, are we creating a tenant permission?"
> **Domain expert:** "No. The service registers a global **Permission Definition** through its **Service Registration**, and organizations may then use that definition in **Custom Roles**."

## Flagged ambiguities

- "Organization" and "tenant" were used for the same concept. Use **Organization** as the canonical domain term and avoid "tenant" except when discussing generic multi-tenancy.
- "Owner" was used to mean both the relationship and the effective access outcome. Use **Ownership Membership** for the relationship and **Ownership Authority** for the access semantics.
- "Membership" and "access" were used too loosely. Use **Membership** for organizational relationship state and **Role Assignment** for explicit RBAC grants.
- "Role" was used to mean both the reusable bundle and the act of granting it. Use **Role Definition** for the bundle and **Role Assignment** for the grant.
- "Permission" was used to mean both a catalog entry and an authorization check input. Use **Permission Definition** for the catalog concept; only use "permission" informally when the context is obvious.
- "Service", "Service Principal", and "Service Registration" were used interchangeably. Use **Client Service** for the integrating system, **Service Principal** for the authenticated machine identity, and **Service Registration** for the governance record.
- "Personal organization" and "home tenant" were used for the same concept. Use **Personal Organization** consistently.
