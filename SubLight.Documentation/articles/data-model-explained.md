<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/14/2025 12:04 AM
-->
# Orchestration Data Context

> ⚠️ **Note:** While this document does not explore the internals of `OrchestrationDataContext`, contributors should expect it to interact with governed models during orchestration. These interactions may include lifecycle hooks, audit triggers, mandate enforcement, and proxy traversal. The context is orchestration-aware and model-sensitive—but its mechanics are out of scope here.

## **Lifecycle Hooks**

### **OnCreateServiceAuthority**

Invoked during the initial bootstrap phase. This hook receives configuration options including service names, environment URIs, and a builder for defining all Service Authorities.

Each authority is established with its canonical identity, semantic location, governed models, and denial-first mandates. This marks the orchestration boundary—where contributor expectations and domain ownership are formalized.

Once an authority is defined, its governed models become orchestration-aware. Model configuration is activated declaratively and scoped to the service abstraction.

After creation, orchestration proceeds to validation.

---

### **OnValidateServiceAuthority**

Invoked after creation, during bootstrap validation. This hook receives the fully constructed Orchestration Data Model (ODM) and performs internal consistency checks.

Validation includes:

- Duplicate configuration across authorities
- Lifecycle flag inconsistencies
- Structural validity of declared access intent

Diagnostics are contributor-facing and CI-ready. Mandate enforcement is deferred to delegation.

---

### **OnDelegateServiceAuthority**

Invoked after validation, during delegation setup in bootstrap. This hook processes access declarations from services that consume models governed by other authorities.

Each consuming service declares intent to access shared models. These declarations are resolved against denial-first mandates issued by the governing authority.

Access delegation is explicit, CI-validatable, and scoped to orchestration contracts.

> 🧮 **Access Mask Resolution**  
> During delegation, declared access intent is resolved against governing mandates.  
> If a service requests access that is partially denied, the resulting mask is pared down to what is explicitly allowed.  
> Diagnostics are emitted only when the resolved mask is empty or violates lifecycle constraints.

---

### **ApplyModelConfiguration**

Not a lifecycle hook, but a reflection-based extension activated during the creation phase. It applies model configuration declaratively, scoped to the service abstraction.

Each configuration defines setup for a governed model—indexes, constraints, lifecycle flags, and audit scope. These are applied without entangling domain abstractions.

Mandates are applied after configuration, defining denial-first constraints that restrict external access to governed models.

---

# **O**rchestration **D**ata **M**odel

Most contributors will read "ODM" and think: **Object Data Model**. That’s fine. It’s the default mental shape—POCOs, fields, maybe some LINQ.

In traditional ORM systems, ODM means mapping objects to tables. It’s about shape fidelity, hydration, and query translation. Contributors expect ODM to behave like a schema proxy—something that serializes, persists, and traverses relational boundaries.

SubLight takes a different approach. ODM here isn’t a mapping layer—it’s a modeling contract. It describes what data looks like, how it behaves, when it lives, and why it matters to orchestration.

If you're still thinking in terms of hydration and persistence, you're in the box. SubLight’s ODM is how you get out.

### ODM: ORM vs SubLight

| Dimension | ORM ODM | SubLight ODM | 
| --- | --- | --- | 
| **Primary Concern** | Shape fidelity and persistence | Lifecycle, orchestration, and semantic intent | 
| **Data Behavior** | Hydration, serialization, query translation | Lifecycle flags, access intent, audit scope | 
| **Contributor Role** | Consumer of schema | Author of orchestration contracts | 
| **Model Boundaries** | Table-driven | Domain-driven, lifecycle-scoped | 
| **Traversal** | LINQ over hydrated objects | Roslyn-safe proxy navigation | 
| **Lifecycle Awareness** | Implicit (via DB context) | Explicit (via bitwise flags) | 
| **Auditability** | Externalized | Modeled directly | 

## Rethinking the "O"

You’ll start with “Object.” Everyone does. But SubLight doesn’t stop there.

The moment you model lifecycle, access intent, or audit scope—you’ve moved beyond passive shape and into orchestration.

And when you group models by semantic boundaries, contributor roles, or compliance zones? You’re modeling domains.

SubLight’s ODM encourages clarity. Not by redefining the acronym, but by asking: **What are you modeling, and why does it matter to orchestration?**

## What Is a Domain?

A domain is not a folder. It’s a boundary of meaning.

In SubLight, domains define contributor intent, compliance scope, and orchestration behavior. They group models by relevance—who uses them, how they behave, and why they matter.

As a developer, a domain might feel like a circle on a chart—encapsulating other circles that may or may not intersect. That’s not just a visual metaphor. It’s a modeling truth. Domains contain, isolate, and relate models by orchestration relevance.

Domains also control abstraction—defining what orchestration means within their boundary, and what modeling patterns are valid inside it.

## Domain-Level Abstractions

SubLight’s ODM is published as a NuGet package for reuse and governance. It defines a domain-level abstraction: a modeling contract that enforces lifecycle semantics, contributor clarity, and orchestration boundaries across the enterprise.

This packaging strategy makes the domain explicit. It tells contributors: here’s the scope, the rules, and the orchestration logic you’re working within.

### Service-Level Abstractions

As services evolve, so does the need to decentralize where POCOs and entity configurations reside. SubLight supports this through **service-level abstractions**—a layer that references the domain abstraction transiently, allowing orchestration-aware libraries within a service to reason about lifecycle, mandates, and contributor roles without entangling runtime logic.

This pattern enables each service to define its own modeling surface while respecting domain boundaries. It also allows CI pipelines to validate orchestration integrity across libraries that share a domain abstraction.

Service-level abstractions are not runtime dependencies—they are orchestration contracts. They declare what the service governs, what it denies, and how it participates in orchestration without flattening the domain. Importantly, the service itself must not reference its abstraction directly—this avoids cyclic dependencies and preserves architectural separation.

## <span style="color:blue;">**O**</span>rchestration <span style="color:blue;">**D**</span>ata <span style="color:blue;">**M**</span>odel

SubLight’s ODM defines orchestration through modeling. It’s not just about shape—it’s about lifecycle, semantics, and contributor clarity. Every model expresses intent

### First Layer: Service Authority

A **Service Authority** is the first layer of SubLight’s Orchestration Data Model. It defines who governs a model, where orchestration applies, and what boundaries must be respected. Every model begins here—not with shape, but with governance.

It contains:

* **Canonical Identity**  
  A simple name that uniquely identifies the service within the orchestration domain. This name is authoritative—it ties models to their governing service and defines contributor expectations.

* **Semantic Location**  
  A URI-like reference that tells orchestration systems where the service listens. It’s not about transport—it’s about resolution. This location is environment-aware and decoupled from orchestration semantics.

* **Governed Models** also known as a <span style="color:blue;">**O**</span>bject <span style="color:blue;">**D**</span>ata <span style="color:blue;">**M**</span>odel<br /> 
  A collection of data models that this authority owns. These models inherit lifecycle flags, audit scope, and contributor roles from the authority. The relationship is one-to-many and domain-scoped.

* **Mandates**  \
  An optional collection of declarative constraints. These do not define models—they define what *other* authorities are denied from doing with models governed by this authority. Mandates are denial-first: they declare what is **not** allowed, using bitwise access masks to keep memory footprint lean.

## Durable vs Aliased Entities

SubLight supports side-by-side modeling of entities that differ in orchestration authority:

* **Durable Entity**  
  A model governed by the current `ServiceAuthority`. It contains full schema fidelity, lifecycle flags, and mandate declarations. Configuration is applied via `IEntityConfiguration<TEntity>` and activated through `ApplyModelConfiguration`.

* **Aliased Entity**  
  A model governed by an external `ServiceAuthority`. Locally, it exists only to declare access intent. It does not participate in lifecycle configuration or mandate declaration. It is not configured via `IEntityConfiguration<TEntity>` and must not be activated through `ApplyModelConfiguration`.

Aliased entities are orchestration-aware but not orchestration-owned. They act as semantic pointers to externally governed models, enabling contributors to declare access intent without duplicating configuration or violating domain boundaries.

This pattern allows contributors to reason about shared models without entangling authority. It also enables CI validation to enforce that aliased entities are never configured locally. Any attempt to do so will result in an `InvalidOperationException` during orchestration validation.

Aliased entities may also support **proxy resolution**—a mechanism by which orchestration systems can locate and interact with the authoritative service that governs the model. This resolution is environment-aware and may use the `Semantic Location` of the external authority to route requests, validate access, or hydrate data.

This enables orchestration-aware services to treat aliased entities as cloud-resolvable references, without assuming ownership or configuration rights. It preserves domain boundaries while enabling distributed access semantics.

> 🧭 **Aliased Entity Cache Behavior**  
> SubLight may support cacheable behavior for aliased entities scoped to the consuming service. This allows orchestration to cache projections of externally governed models without violating domain ownership.  
>  
> When enabled, the cache key must include the consuming `ServiceAuthority` to ensure traceability and avoid collisions. The consuming authority must also declare cache awareness and own invalidation rights for its scoped entries.  
>  
> The cache remains external to the service—never in-memory. This ensures orchestration visibility, fast execution, and domain-respectful modeling.

---

## Ephemeral Entities

SubLight supports a third modeling category alongside durable and aliased entities: the **Ephemeral Entity**.

An Ephemeral Entity is orchestration-aware but not governed. It does not map directly to a schema and is not persisted in a durable store. Instead, it is projected from durable or aliased entities to express transient orchestration logic.

Despite its transient nature, an Ephemeral Entity may be configured declaratively to express projection origin, lifecycle scope, and orchestration behavior—without entangling domain ownership.

### Characteristics

- **Projection-Based**: Composed from durable or aliased entities  
- **No Schema Fidelity**: Not mapped to a backing schema  
- **Configurable**: Declared via modeling contract, not runtime logic  
- **Keyed**: Anchored to a durable source via a data key  
- **Cacheable**: May be persisted in distributed cache  
- **Orchestration-Scoped**: Exists only within orchestration context

### Modeling Implications

Ephemeral Entities share no schema with their durable counterparts. The only structural overlap is the data key, which anchors the ephemeral projection to its root durable source. This key enables cache addressability, proxy traversal, and audit traceability.

> 🔁 **Cache Resolution**  
> The data key anchors ephemeral entities to their durable origin. When cache is enabled, orchestration uses this key to resolve the projection from distributed cache. If valid, the cached object is used directly—avoiding recomputation from the durable store.

> 🧠 **Contributor Insight**  
> Ephemeral Entities in SubLight behave like AutoMapper projections in traditional EF Core systems. They are shaped from durable sources, keyed for traceability, and modeled for orchestration—not persistence.

> 💡 **Performance Note**  
> Some ephemeral projections may be expensive to compute. SubLight’s support for cacheable ephemeral entities allows contributors to persist transient results in distributed cache—reducing recomputation and improving orchestration performance.

> ⚠️ **Contributor Warning**  
> Ephemeral entities may be cacheable, but caching must occur at the orchestration layer—not within service internals. SubLight discourages runtime-layer caching of projections, as it obscures orchestration boundaries and undermines contributor clarity.

> 🧭 **Cache Location Principle**  
> SubLight services must remain lean and orchestration-focused. All cache behavior—whether for ephemeral or aliased entities—must be externalized. This ensures fast execution, clear modeling boundaries, and orchestration-aware cache resolution.  
>  
> Even when a consuming service caches an aliased projection, the cache must reside outside the service boundary. The `ServiceAuthority` must declare cache awareness and own invalidation rights for its scoped entries. The cache key must include the consuming authority’s identity to ensure isolation and traceability.  
>  
> Internal service caching is discouraged—even for performance-sensitive projections—as it obscures orchestration boundaries and undermines contributor clarity.

---

### Ephemeral Configuration Metadata

Ephemeral entities may declare orchestration-aware configuration metadata to guide cache behavior and lifecycle scope. This metadata is not runtime logic—it is a modeling contract that informs orchestration systems how to treat the projection.

#### Supported Modes

| Mode | Description | Contributor Intent |
|------|-------------|--------------------|
| **Invalidation-Based** | Entity remains valid until explicitly invalidated by upstream change or domain trigger | Use when projections are stable but sensitive to source mutation |
| **Timeout-Based** | Entity expires after a defined duration | Use when projections are cheap to recompute or time-sensitive |

#### Configuration Surface

Contributors may declare ephemeral configuration using modeling contracts—not runtime logic. This ensures orchestration visibility and avoids service-layer leakage.

> ⚠️ **Note**  
> SubLight does not support in-memory expiration logic. All timeout or invalidation behavior must be modeled for orchestration and resolved via distributed cache.

> 🧾 **Cacheable Entities Must Declare Behavior**  
> In SubLight, declaring an entity as cacheable is not a performance hint—it is a modeling contract. Contributors must define the expected cache behavior when marking an entity as cacheable. This includes:  
>  
> - **Expiration Strategy**: Whether the entity expires via timeout or remains valid until explicitly invalidated  
> - **Invalidation Triggers**: What upstream changes or domain events cause the cache to be purged  
> - **Scope and Visibility**: Whether the cache is session-scoped, domain-scoped, or globally distributed  
>  
> Cache behavior must be orchestration-aware and CI-validatable. Runtime-layer caching without declared behavior is discouraged and may result in orchestration diagnostics.