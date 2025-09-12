<!-- Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:

* Free for educational, research, personal, or nonprofit use
* Commercial use requires a paid license

See [LICENSE.dual.md](https://LICENSE.dual.md) for full terms. -->

# SubLight D.O.C. Architecture

SubLight is a distributed object coordinator—a stateless orchestration framework that unifies identity, caching, access intent, and telemetry across SQL, NoSQL, and in-memory stores.

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

### 📘 Table of Contents

* [Access Intent and Telemetry](#-access-intent-and-telemetry)
* [Orchestration Data Model (Enterprise Perspective)](#-orchestration-data-model-enterprise-perspective)
* [Navigation Property Resolution](#-navigation-property-resolution)
* [Distributed Change Tracking (Exploratory Notes)](#-distributed-change-tracking-exploratory-notes)
* [Service Ownership and Model Shifting](#-service-ownership-and-model-shifting)
* [Query Surface and Resolution Semantics](#-query-surface-and-resolution-semantics)
* [Speculative Transport Optimization](#-speculative-transport-optimization)

---

### 🔐 Access Intent and Telemetry  
*Declarative sensitivity tiers that guide resolution behavior and trigger audit telemetry in regulated environments.*

<details><summary>Expand details</summary>

SubLight supports declarative access control and telemetry escalation for regulated environments.

* Entities may declare an AccessIntent to signal sensitivity, enforce access boundaries, and trigger audit or telemetry escalation when resolved.
* AccessIntent declarations are enforced at the provider level:
  * **Forbidden**: The provider must throw or fail fast—no resolution allowed.
  * **Restricted**: The provider must log the access, trigger telemetry escalation, and optionally require justification or context.
  * **Public**: Resolution proceeds normally, with optional lightweight telemetry.
* Telemetry sinks record access and escalate when protected data is resolved:
  * Record access event with metadata (who, when, what, why)
  * Elevate telemetry level (e.g. trace, audit, alert)
  * Optionally notify compliance or trigger review workflows
* Orchestration respects declared access boundaries to prevent accidental exposure

This enables SubLight to operate safely in environments governed by HIPAA, GDPR, or similar regulations—without compromising orchestration flexibility.

</details>

---

### 🧠 Orchestration Data Model (Enterprise Perspective)  
*Declarative entity lifecycles and persistence tiers that coordinate orchestration across services.*

_SubLight models are declared within the scope of their owning service. Service Authority is the primary contract—models are defined downstream of that authority to preserve orchestration clarity and governance alignment. This also enables contributors to unify models across multiple service authorities using select-many queries, supporting DRY principles and cross-domain orchestration._

<details><summary>Expand details</summary>

SubLight orchestration relies on a shared enterprise data model to coordinate behavior across services and instances. This model defines the semantic boundaries and lifecycle intent of each entity, enabling predictable orchestration without ambient assumptions.

Each entity model in SubLight is declared under a specific service authority. This authority governs lifecycle, mutation rights, and orchestration boundaries.

Entities must explicitly declare:

#### 🛡️ Declared Service Authority

SubLight entities must declare which service is the canonical source of truth for the entity.

* Specifies full **C.R.U.D.** permissions (Create, Retrieve, Update, Delete) for the owning service
* Treats all other services as **forbidden** by default unless explicitly declared
* Enables orchestration to enforce boundaries and prevent unauthorized resolution attempts
* Read-only access is a permission level, not an access intent tier. Authority declarations are used to enforce contract boundaries and prevent unauthorized mutation.

#### 🧱 Schema Fidelity and Property Mapping

SubLight entities must support schema fidelity and property-level declarations consistent with traditional ORM patterns (e.g., Entity Framework, Hibernate, Sequelize).

* **Table Equivalence** — Durable entities must map to a schema-defined table or collection, with a declared `PersistenceIntent.Persistent`
* **Property Mapping** — Entities expose primitive types, navigation properties, and computed fields, declared explicitly for LINQ surface generation
* **Behavioral Parity with ORM Expectations**
  * Change tracking is externalized via envelope metadata
  * Navigation properties are resolved via proxy generation
  * Query composition mirrors LINQ semantics, including filtering, projection, and joins
  * Schema evolution is supported via declarative contract updates, not ambient migration

This ensures contributors can reason about entities using familiar ORM patterns, while benefiting from SubLight’s stateless, provider-neutral orchestration.

</details>

---

### 🔄 Navigation Property Resolution  
*Proxy-based relationship resolution with cache-aware orchestration semantics.*

<details><summary>Expand details</summary>

SubLight supports navigation properties via Roslyn-generated proxies. These proxies allow entities to expose relationships (e.g. `Customer.Orders`) while preserving orchestration semantics.

When the entity targeted by a navigation property is marked as **Cachable**, resolution follows this flow:

1. **Envelope Check** — Inspect envelope metadata for freshness  
2. **Cache Lookup** — Query distributed cache using declared `DataKey`  
3. **Provider Fallback** — Resolve via durable backend if cache miss occurs  
   > 📘 Fallback respects `PersistenceIntent`; ephemeral entities won’t trigger durable resolution  
4. **Telemetry Trigger** — If read access is declared but mutation is forbidden, telemetry sinks may escalate unauthorized mutation attempts

</details>

---

### 🔄 Distributed Change Tracking (Exploratory Notes)  
*Declarative mutation signaling and dirty state coordination for cacheable entities.*

<details><summary>Expand details</summary>

SubLight recognizes the architectural value of distributed change tracking—especially in cacheable, mutation-prone entities. While not fully implemented in version 1, the following concepts are under active consideration:

* **Mutation Intent Signaling**  
  When a user accesses an entity with intent to modify, orchestration may capture this as a declarative signal—externalized via envelope metadata

* **Dirty State Coordination**  
  For entities marked `PersistenceIntent.Cachable`, SubLight may flag the record as **dirty**—indicating that resolution should be deferred until changes are committed or rolled back

* **Deferred Resolution Behavior**  
  Consumers attempting to resolve a dirty entity may receive stale data, a deferred response, or a fail-fast signal depending on orchestration policy

* **Commit/Rollback Semantics**  
  Coordinating distributed commits and rollbacks remains an open question. SubLight does not yet implement transaction orchestration across services or providers

> 📘 This section is exploratory. It signals architectural intent and acknowledges that some behaviors may evolve in future versions. Contributors are encouraged to reason declaratively and avoid ambient assumptions.

</details>

---

### 🧩 Service Ownership and Model Shifting  
*Declarative stewardship and envelope authority transitions across evolving domains.*

<details><summary>Expand details</summary>

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

</details>

---

### 🔍 Query Surface and Resolution Semantics  
*LINQ-based query composition that respects orchestration boundaries and entity intent.*

<details><summary>Expand details</summary>

SubLight exposes a unified query surface via LINQ. This allows developers to:

* Filter, project, and join data without knowing the underlying store  
* Compose queries that flow through cache, envelope resolution, and provider logic  
* Resolve queries based on declared entity intent—respecting cacheability, persistence, and orchestration rules  
* Maintain separation of concerns between orchestration and business logic

</details>

### 🚀 Speculative Transport Optimization  
*Exploring binary transport and expression tree delegation for efficient orchestration.*

<details><summary>Expand details</summary>

SubLight contributors have noted the overhead of verbose JSON payloads and OData query strings—especially in high-throughput orchestration scenarios. While HTTP/2 improves multiplexing, it does not compress semantic metadata or reduce payload bloat.

Future optimization may include:

* **Declarative Compression Layer** — Mapping orchestration metadata into compact binary frames or tokenized envelopes  
  * Bitwise encoding of `AccessIntent`, `PersistenceIntent`, and `EnvelopeAuthority`  
  * Tokenized navigation paths instead of full JSON expansions  
  * Audit metadata streamed separately via telemetry sinks

* **gRPC and Protobuf Transport** — Leveraging binary serialization and service contracts to reduce transport cost  
  * Expression tree segments may be passed to the steward  
  * Steward resolves the requested entity and returns it via gRPC  
  * Enables efficient, contract-driven orchestration with reduced payload size

This speculative model would preserve declarative semantics while improving transport efficiency—especially for cacheable, telemetry-sensitive entities.

</details>
---

## 🔧 Core Abstractions

These are the building blocks that implement the Enterprise Data Model within SubLight.

### DataKey

A composable identifier that abstracts entity identity across stores. Supports:

* Simple and composite keys  
* Bulk resolution  
* Provider-neutral semantics  

### DataEnvelope

A metadata wrapper that carries versioning, timestamps, and cache hints. Enables:

* Envelope-aware caching  
* Consistency coordination  
* Providers interpret envelope metadata to coordinate caching, consistency, and fallback behavior—enabling extensibility without modifying core abstractions.

### Design Principles
* **Statelessness**: No ambient context, no hidden dependencies.
* **Explicitness**: All orchestration is opt-in and declarative.
* **Extensibility**: Providers can be added without modifying core abstractions.
* **Separation of Concerns**: Query logic, caching, and storage are cleanly decoupled.

SubLight is designed to evolve. New orchestration behaviors, access policies, and provider types can be introduced without modifying core abstractions—preserving stability and extensibility.

### Comparison to Existing Systems
SubLight draws inspiration from several established categories, but it combines their strengths into a unified, stateless orchestration layer. Here's how it compares:

| System Type | What It Does | What SubLight Adds |
|-------------|--------------|---------------------|
| **ORMs** (e.g. EF Core, Dapper) | Abstract SQL access and object mapping | Provider-neutral abstraction, cache-aware orchestration, LINQ surface |
| **Cache Managers** (e.g. MemoryCache, Redis) | Manage in-memory and distributed caching | Envelope-driven coordination, cache invalidation tied to identity and metadata |
| **Service Meshes** (e.g. Istio, Consul) | Route and secure service-to-service traffic | Data-level orchestration, query abstraction, no runtime dependency |
| **CQRS/Event Sourcing Frameworks** (e.g. Orleans, Akka.NET) | Separate read/write models and coordinate state | Unified query surface, stateless design, LINQ-driven access |
| **Data Virtualization Platforms** (e.g. Denodo, TIBCO) | Unify access to multiple data sources | Lightweight, code-first orchestration with extensible provider model |

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

* [Keys and Envelopes](keys-and-envelopes.md)  
* [Bulk Operations](bulk-operations.md)  
* [Extensibility Guidelines](extensibility.md)  
* [Contributor Onboarding](onboarding.md)
