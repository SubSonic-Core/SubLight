<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight D.O.C. Architectural Concepts

SubLight is a distributed object coordinator—a stateless orchestration framework that unifies identity, caching, access intent, and telemetry across SQL, NoSQL, and in-memory stores.

### 📘 Table of Contents

- [Purpose](#purpose)
- [Core Concepts](#core-concepts)
  - [Access Sensitivity and Telemetry](#-access-sensitivity-and-telemetry)
  - [Orchestration Data Model (Enterprise Perspective)](#-orchestration-data-model-enterprise-perspective)
  - [Navigation Property Resolution](#-navigation-property-resolution)
  - [Distributed Change Tracking (Exploratory Notes)](#-distributed-change-tracking-exploratory-notes)
  - [Service Ownership and Model Shifting](#-service-ownership-and-model-shifting)
  - [Query Surface and Resolution Semantics](#-query-surface-and-resolution-semantics)
  - [Speculative Transport Optimization](#-speculative-transport-optimization)
  - [Comparison to Existing Systems](#-comparison-to-existing-systems)
- [Deployment Model](#deployment-model)
- [Why SubLight?](#why-sublight)
- [Contributor Summary](#contributor-summary)
- [Next Steps](#next-steps)

## Purpose

SubLight exists to solve a recurring architectural tension: how to coordinate data access and caching across multiple instances of a service or application, without coupling logic to storage, cache, or orchestration layers.

It provides:

* A **LINQ-compatible query surface** for developers to express intent
* A **provider-neutral abstraction** over SQL, NoSQL, and in-memory stores
* A **cache-aware orchestration layer** that respects keys, envelopes, and bulk operations
* A **stateless design** that scales horizontally and avoids fragile integrations

---

## Core Concepts

*Each section below expands to reveal a foundational orchestration concept.*

### 🔐 Access Sensitivity and Telemetry

*Declarative sensitivity tiers that guide resolution behavior and trigger audit telemetry in regulated environments.*

<details><summary>Expand details</summary> <br /> 

SubLight supports declarative access sensitivity and telemetry escalation for regulated environments. These declarations guide how entities are resolved, audited, and escalated—without implying mutation rights or service authority.

Entities may declare a **TelemetryTier** to signal sensitivity, enforce access boundaries, and trigger audit or telemetry escalation when resolved.

#### 🧠 TelemetryTier Enforcement

TelemetryTier declarations are enforced at the provider level:

* **Forbidden** — The provider must throw or fail fast; resolution is blocked entirely
* **Restricted** — The provider must log the access, trigger telemetry escalation, and optionally require justification or context
* **Public** — Resolution proceeds normally, with optional lightweight telemetry

Telemetry sinks record access and escalate when protected data is resolved:

* Record access event with metadata (who, when, what, why)
* Elevate telemetry level (e.g. trace, audit, alert)
* Optionally notify compliance or trigger review workflows

#### 🚫 Mutation Rights Are Not Implied

TelemetryTier does not grant mutation rights. Mutation is governed by **Declared Service Authority** and any **DelegatedAuthority** contracts. A service may resolve sensitive data under telemetry, but cannot mutate it unless explicitly authorized.

This enables SubLight to operate safely in environments governed by HIPAA, GDPR, or similar regulations—without compromising orchestration flexibility or conflating sensitivity with permission. </details>

---

### 🧠 Orchestration Data Model (Enterprise Perspective)

*Declarative entity lifecycles and persistence tiers that coordinate orchestration across services.*

<details><summary>Expand details</summary> <br /> 

SubLight orchestration relies on a shared enterprise data model to coordinate behavior across services and instances. This model defines the semantic boundaries and lifecycle intent of each entity, enabling predictable orchestration without ambient assumptions.

Each entity model in SubLight is declared under a specific service authority. This authority defines the canonical source of truth for the entity and governs lifecycle, mutation rights, and orchestration boundaries.

Entities must explicitly declare:

#### 🛡️ Declared Service Authority

SubLight entities must declare which service is the canonical source of truth for the entity.

* Uses a combination of service name and URI semantics to establish authority for object coordination
* Specifies full **C.R.U.D.** permissions (Create, Retrieve, Update, Delete) for the owning service
* Treats all other services as **forbidden** by default unless explicitly declared
* Enforces contract boundaries and prevents unauthorized resolution attempts

#### 🧩 Shared Model Across Applications

SubLight’s orchestration data model is not scoped to a single application—it is shared across services, environments, and deployment tiers.

* The model defines **entity semantics** that are consistent across all consumers
* Each application may declare its own **DelegatedAuthorityFlags**, but must respect the canonical **DeclaredServiceAuthority**
* Entity declarations are versioned and governed centrally, ensuring schema fidelity and orchestration consistency
* Envelope metadata and telemetry sinks operate across service boundaries, enabling distributed resolution and mutation tracking

This shared model enables SubLight to coordinate behavior across:

* Load-balanced IIS servers
* Containerized microservices
* Staging and production environments
* External partner integrations

Contributors reason about orchestration as a **shared contract**, not a local implementation detail.

#### 📦 NuGet-Based Authority Declaration

To ensure consistency and governance across the enterprise, SubLight recommends delivering the orchestration data model as a **NuGet package**. This package should:

* Declare **service authority** for each entity
* Include **POCO definitions** scoped to each service
* Encode **DelegatedAuthorityFlags** for non-owning services
* Version entity contracts and schema declarations centrally
* Enable contributors to reason about orchestration via shared, discoverable types

This approach ensures that all applications consume a consistent orchestration model, respect declared authority, and participate in envelope coordination and telemetry escalation without ambient assumptions.

#### 🚫 Explicitly Forbidden Access

In some cases, the enterprise may explicitly forbid access from a service—especially when that service is external-facing and bridges inside the firewall.

* This prevents sensitive internal data from leaking to public-facing portals
* Forbidden declarations are enforced at orchestration boundaries and provider level
* TelemetryTier may be set to **Forbidden**, and DelegatedAuthorityFlags omitted entirely
* Envelope resolution and query surface exposure are blocked for forbidden services

This ensures that orchestration contracts respect enterprise boundaries and prevent accidental data exposure across trust zones.

</details>

---

### 🔄 Navigation Property Resolution

*Proxy-based relationship resolution with cache-aware orchestration semantics.*

<details><summary>Expand details</summary> <br /> 

SubLight supports navigation properties via Roslyn-generated proxies. These proxies allow entities to expose relationships (e.g. `Customer.Orders`) while preserving orchestration semantics.

When the entity targeted by a navigation property is marked as **Cacheable**, resolution follows this flow:

1. **Envelope Check** — Inspect envelope metadata for freshness  
2. **Cache Lookup** — Query distributed cache using declared `DataKey`  
3. **Provider Fallback** — Resolve via durable backend if cache miss occurs  
4. **Telemetry Trigger** — If read access is declared but mutation is forbidden, telemetry sinks may escalate unauthorized mutation attempts

</details>

---

### 🔄 Distributed Change Tracking (Exploratory Notes)

*Declarative mutation signaling and dirty state coordination for cacheable entities.*

<details><summary>Expand details</summary> <br /> 

SubLight recognizes the architectural value of distributed change tracking—especially in cacheable, mutation-prone entities. While not fully implemented in version 1, the following concepts are under active consideration:

* **Mutation Intent Signaling** When a user accesses an entity with intent to modify, orchestration may capture this as a declarative signal—externalized via envelope metadata  
* **Dirty State Coordination** For entity declarations with `Orchestration Behavior: Cacheable`, SubLight may flag the record as **dirty**—indicating that resolution should be deferred until changes are committed or rolled back  
* **Deferred Resolution Behavior** Consumers attempting to resolve a dirty entity may receive stale data, a deferred response, or a fail-fast signal depending on orchestration policy  
* **Commit/Rollback Semantics** Coordinating distributed commits and rollbacks remains an open question. SubLight does not yet implement transaction orchestration across services or providers

> 📘 This section is exploratory. It signals architectural intent and acknowledges that some behaviors may evolve in future versions. Contributors are encouraged to reason declaratively and avoid ambient assumptions.

</details>

---

### 🧩 Service Ownership and Model Shifting

*Declarative stewardship and envelope authority transitions across evolving domains.*

<details><summary>Expand details</summary> <br /> 

SubLight treats service ownership as a declarative contract, not a static assignment. Ownership is scoped to orchestration boundaries and anchored in service authority.

Ownership declarations include:

* **Entity Stewardship** — The service responsible for defining the entity’s schema, lifecycle, and cacheability  
* **Envelope Authority** — The service that governs metadata resolution and change tracking  
* **Query Surface Exposure** — The service that exposes LINQ queries and resolution logic

Ownership may shift across services as business domains evolve. SubLight supports this by:

* Declaring service authority first, then scoping models within that declaration  
* Reassigning envelope authority and query exposure via contract updates—not structural migrations  
* Enforcing permission boundaries through orchestration metadata

When stewardship of a durable model shifts from one provider to another (e.g., from database A to database B), SubLight’s migration tooling can generate change scripts to step through the transition. This includes migrating existing data to the new provider—a bandwidth-expensive but feasible operation.

This model allows SubLight to coordinate across distributed services while respecting local autonomy and enterprise alignment. Contributors reason about **who governs** before they reason about **what is governed**.

#### ⏱️ Bootstrap-Time Authority Alignment

Enterprise architects should note that **DeclaredServiceAuthority** is resolved and locked during service bootstrap. This ensures:

* 🌐 **Environment-specific URI alignment** (e.g. staging vs. production)
* 🔐 **Immutable authority contracts** post-startup
* 🚫 **DelegatedAuthority declarations may be blocked or overridden** by the enterprise ODM. This includes scenarios where a consuming service requests full C.R.U.D. access (Create, Retrieve, Update, Delete) for an entity, but the ODM enforces stricter boundaries—such as denying delete rights or restricting mutation entirely.

This override mechanism also supports scenarios where a service is **explicitly denied the ability to opt in** to delegated access. For example, an external-facing service that bridges inside the firewall may be prohibited from resolving or mutating sensitive internal entities, regardless of its declared intent.

This pattern prevents ambient resolution drift and enforces orchestration boundaries across trust zones. Authority is declared once—at startup—not inferred or mutated at runtime.
</details>

---

### 🔍 Query Surface and Resolution Semantics

*LINQ-based query composition that respects orchestration boundaries and entity intent.*

<details><summary>Expand details</summary> <br /> SubLight exposes a unified query surface via LINQ. This allows developers to:

* Filter, project, and join data without knowing the underlying store
* Compose queries that flow through cache, envelope resolution, and provider logic
* Resolve queries based on declared entity intent—respecting cacheability, persistence, and orchestration rules
* Maintain separation of concerns between orchestration and business logic

This orchestration model assumes that downstream providers—including ORMs—can participate in expression-driven resolution. While implementation details belong in extensibility guidelines, the core concept is that SubLight delegates query intent declaratively, and providers must expose a compatible query surface to receive and execute those expressions.

</details>

---

### 🚀 Speculative Transport Optimization

*Exploring binary transport and expression tree delegation for efficient orchestration.*

<details><summary>Expand details</summary> <br /> SubLight contributors have noted the overhead of verbose JSON payloads and OData query strings—especially in high-throughput orchestration scenarios. While HTTP/2 improves multiplexing, it does not compress semantic metadata or reduce payload bloat.

Future optimization may include:

* **Declarative Compression Layer** — Mapping orchestration metadata into compact binary frames or tokenized envelopes
  * Bitwise encoding of `AccessIntent`, `PersistenceIntent`, and `EnvelopeAuthority`
  * Tokenized navigation paths instead of full JSON expansions
  * Audit metadata streamed separately via telemetry sinks

* **HTTP/2 Transport** — Leveraging binary serialization to reduce transport cost  
  * Steward resolves the requested entity and returns it via HTTP/2
  * Enables efficient, contract-driven orchestration with reduced payload size

This speculative model would preserve declarative semantics while improving transport efficiency—especially for cacheable, telemetry-sensitive entities.

</details>

### 🧭 Comparison to Existing Systems

*How SubLight differs from traditional data access, caching, and orchestration frameworks.*

SubLight draws inspiration from several established categories—but it unifies their strengths into a stateless, declarative orchestration layer. Unlike traditional systems that couple logic to storage, cache, or runtime dependencies, SubLight coordinates resolution behavior across distributed services using explicit contracts and LINQ-native semantics.

| System Type | Traditional Role | What SubLight Replaces or Refines | 
| --- | --- | --- | 
| **ORMs** (e.g. EF Core, Dapper) | Abstract SQL access and object mapping | Provider-neutral abstraction, cache-aware orchestration, LINQ surface | 
| **Cache Managers** (e.g. MemoryCache, Redis) | Manage in-memory and distributed caching | Envelope-driven coordination, cache invalidation tied to identity and metadata | 
| **Service Meshes** (e.g. Istio, Consul) | Route and secure service-to-service traffic | Data-level orchestration, query abstraction, no runtime dependency | 
| **CQRS/Event Sourcing Frameworks** (e.g. Orleans, Akka.NET) | Separate read/write models and coordinate state | Unified query surface, stateless design, LINQ-driven access | 
| **Data Virtualization Platforms** (e.g. Denodo, TIBCO) | Unify access to multiple data sources | Lightweight, code-first orchestration with extensible provider model | 

SubLight doesn’t compete with these systems—it abstracts and simplifies their orchestration concerns. Contributors reason declaratively, without ambient assumptions or runtime coupling.

### Deployment Model

SubLight is designed to be deployed as a library within your application or service. It does not require a separate server or daemon, making it easy to integrate into existing architectures.

It supports both containerized and load-balanced environments:

#### Docker-Based Deployments

* Multiple containers of the same service can run in parallel
* Each container operates independently and statelessly
* Cache state is shared via distributed providers (e.g. Redis, HybridCache)
* Queries are resolved via LINQ and provider contracts
* No shared memory or ambient context required

#### IIS Load-Balanced Servers

* Multiple servers host one instance of the application each
* IIS coordinates traffic across instances
* Each instance behaves like a standalone orchestration node
* Cache coordination and query resolution follow the same stateless model

Whether deployed via Docker, Kubernetes, or IIS, SubLight ensures:

* Predictable behavior across instances
* Stateless orchestration with no runtime dependencies
* Cache-aware coordination without tight coupling

This flexibility makes SubLight ideal for hybrid environments—where some services run in containers, others behind IIS, and all need consistent access to shared data.

---

## Why SubLight?

SubLight exists to simplify what backend systems typically get wrong: coordinating data access, caching, and consistency across distributed services.

Without SubLight, developers are forced to:

* Reimplement cache logic in every repository
* Couple queries to fragile ORM or store-specific APIs
* Handle bulk operations manually, often inconsistently
* Navigate envelope metadata without a shared abstraction

SubLight solves this by introducing a stateless orchestration layer that:

* Unifies access through a LINQ-compatible query surface
* Coordinates caching via envelope-aware resolution
* Abstracts providers without leaking implementation details
* Enables bulk operations and key composition with minimal friction

SubLight is leverage. It’s the architectural boundary that makes everything else simpler, clearer, and easier to maintain.

## Contributor Summary

SubLight orchestration is:

* Declarative: Entities define orchestration behavior via explicit intent
* Stateless: No ambient context or shared memory assumptions
* Extensible: Providers, envelopes, and access policies evolve independently
* Compliant: AccessIntent and telemetry escalation support regulated environments
* Unified: LINQ queries coordinate across cache, store, and metadata layers

## Next Steps

To explore SubLight’s abstractions and contributor workflows:

* [Core Abstractions](core-abstractions.md)
* [Keys and Envelopes](keys-and-envelopes.md)
* [Bulk Operations](bulk-operations.md)
* [Extensibility Guidelines](extensibility.md)
* [Contributor Onboarding](onboarding.md)
* [Glossary of Terms](glossary.md)
