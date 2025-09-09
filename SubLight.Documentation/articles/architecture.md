# SubLight Architecture

SubLight is a distributed object coordinator—a stateless orchestration framework that unifies identity, caching, access intent, and telemetry across SQL, NoSQL, and in-memory stores.

## Purpose

SubLight exists to solve a recurring architectural tension: how to coordinate data access and caching across multiple instances of a service or application, without coupling logic to storage, cache, or orchestration layers.

It provides:

- A **LINQ-compatible query surface** for developers to express intent
- A **provider-neutral abstraction** over SQL, NoSQL, and in-memory stores
- A **cache-aware orchestration layer** that respects keys, envelopes, and bulk operations
- A **stateless design** that scales horizontally and avoids fragile integrations

## Core Concepts

### 🔐 Access Intent and Telemetry

SubLight supports declarative access control and telemetry escalation for regulated environments.

- Entities may declare an AccessIntent to signal sensitivity, enforce access boundaries, and trigger audit or telemetry escalation when resolved.
- AccessIntent declarations are enforced at the provider level.
    - **Forbidden**: The provider must throw or fail fast—no resolution allowed.
    - **Restricted**: The provider must log the access, trigger telemetry escalation, and optionally require justification or context.
    - **Public**: Resolution proceeds normally, with optional lightweight telemetry. 
- Telemetry sinks record access and escalate when protected data is resolved
    - Record access event with metadata (who, when, what, why)
    - Elevate telemetry level (e.g. trace, audit, alert)
    - Optionally notify compliance or trigger review workflows.
- Orchestration respects declared access boundaries to prevent accidental exposure  

This enables SubLight to operate safely in environments governed by HIPAA, GDPR, or similar regulations—without compromising orchestration flexibility.

### 🧠 Enterprise Data Model

SubLight orchestration relies on a shared enterprise data model to coordinate behavior across services and instances. This model defines the semantic boundaries and lifecycle intent of each entity, enabling predictable orchestration without ambient assumptions.

Entities must explicitly declare:

- **Identity**: What constitutes a `DataKey` (e.g. single ID, composite key)
- **Access Intent**: Sensitivity, access boundaries and trigger audit behavior.
- **Persistence Intent**: Persistant, Cachable, Ephemeral, Scoped 
- **Envelope Metadata**: Versioning, timestamps, consistency hints
- **Query Surface**: Which LINQ expressions are supported and how they map to providers

#### 🧩 Service Ownership and Model Shifting

SubLight does not assume a static or centralized model. Instead, the enterprise model is **distributed and declarative**—allowing services to define and own their portion of the data contract.

For example:

- The **Customer Service** may own the `Customer` entity, define its key structure, and declare its cacheability.
- The **Order Service** may own the `Order` entity, define its envelope metadata, and expose LINQ queries for bulk resolution.

SubLight coordinates across these boundaries by respecting each service’s declarations. This allows the model to **shift and evolve** as ownership changes, without breaking orchestration.

Providers interpret entity intent locally, but orchestration remains consistent globally—thanks to the shared contract.

### 🧭 Entity Declaration Matrix

| Declaration | Enables | Interpreted By |
|-------------|---------|----------------|
| `DataKey` | Identity resolution | All providers |
| Access intent | Access control + audit triggers | Providers + telemetry sinks |
| Persistence intent | Provider orchestration | Durable stores |
| Cacheability | Envelope resolution | Cache layers |
| Envelope metadata | Consistency coordination | Cache + store providers |
| LINQ surface | Query composition | Query providers |

### LINQ Queries

SubLight exposes a unified query surface via LINQ. This allows developers to:

- Filter, project, and join data without knowing the underlying store.
- Compose queries that flow through cache, envelope resolution, and provider logic.
- Resolve queries based on declared entity intent—respecting cacheability, persistence, and orchestration rules.
- Maintain separation of concerns between orchestration and business logic.

Example:

```csharp
var activeUsers = await context.Users
    .Where(u => u.IsActive)
    .ToListAsync();
```
This query may resolve from in-memory cache, distributed cache, or a backing store—depending on envelope state and orchestration rules.



## 🔧 Core Abstractions

These are the building blocks that implement the Enterprise Data Model within SubLight.

### DataKey

A composable identifier that abstracts entity identity across stores. Supports:

- Simple and composite keys  
- Bulk resolution  
- Provider-neutral semantics  

### DataEnvelope

A metadata wrapper that carries versioning, timestamps, and cache hints. Enables:

- Envelope-aware caching  
- Consistency coordination  
- Providers interpret envelope metadata to coordinate caching, consistency, and fallback behavior—enabling extensibility without modifying core abstractions.

### Design Principles
- **Statelessness**: No ambient context, no hidden dependencies.
- **Explicitness**: All orchestration is opt-in and declarative.
- **Extensibility**: Providers can be added without modifying core abstractions.
- **Separation of Concerns**: Query logic, caching, and storage are cleanly decoupled.

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
- Multiple containers of the same service can run in parallel
- Each container operates independently and statelessly
- Cache state is shared via distributed providers (e.g. Redis, HybridCache)
- Queries are resolved via LINQ and provider contracts
- No shared memory or ambient context required

#### IIS Load-Balanced Servers
- Multiple servers host one instance of the application each
- IIS coordinates traffic across instances
- Each instance behaves like a standalone orchestration node
- Cache coordination and query resolution follow the same stateless model

Whether deployed via Docker, Kubernetes, or IIS, SubLight ensures:
- Predictable behavior across instances
- Stateless orchestration with no runtime dependencies
- Cache-aware coordination without tight coupling

This flexibility makes SubLight ideal for hybrid environments—where some services run in containers, others behind IIS, and all need consistent access to shared data.

## Why SubLight?
SubLight exists to simplify what backend systems typically get wrong: coordinating data access, caching, and consistency across distributed services.

Without SubLight, developers are forced to:

- Reimplement cache logic in every repository
- Couple queries to fragile ORM or store-specific APIs
- Handle bulk operations manually, often inconsistently
- Navigate envelope metadata without a shared abstraction

SubLight solves this by introducing a stateless orchestration layer that:

- Unifies access through a LINQ-compatible query surface
- Coordinates caching via envelope-aware resolution
- Abstracts providers without leaking implementation details
- Enables bulk operations and key composition with minimal friction

SubLight is leverage. It’s the architectural boundary that makes everything else simpler, clearer, and easier to maintain.

## Contributor Summary

SubLight orchestration is:

- Declarative: Entities define orchestration behavior via explicit intent  
- Stateless: No ambient context or shared memory assumptions  
- Extensible: Providers, envelopes, and access policies evolve independently  
- Compliant: AccessIntent and telemetry escalation support regulated environments  
- Unified: LINQ queries coordinate across cache, store, and metadata layers  

## Next Steps

To explore SubLight’s abstractions and contributor workflows:

- [Keys and Envelopes](keys-and-envelopes.md)  
- [Bulk Operations](bulk-operations.md)  
- [Extensibility Guidelines](extensibility.md)  
- [Contributor Onboarding](onboarding.md)
