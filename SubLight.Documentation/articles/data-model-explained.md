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

This lifecycle hook is defined and invoked by the `OrchestrationDataContext` during its bootstrap phase. It receives configuration options that include a modeled list of service names and their environment URIs, along with a builder that declaratively defines all Service Authorities.

Each authority is established with its canonical identity, semantic location, governed models, and mandates. This hook represents the orchestration boundary map—where contributor expectations, domain ownership, and denial-first semantics are formalized.

Once a Service Authority is defined, its governed models become orchestration-aware. The context uses the runtime implementation of the authority to invoke `ApplyModelConfiguration`—a reflection-based extension that activates model configuration scoped to the service abstraction. See [ApplyModelConfiguration](#applymodelconfiguration) for details.

### **OnValidateServiceAuthority**

This lifecycle hook is invoked by the `OrchestrationDataContext` after `OnCreateServiceAuthority` completes. It receives the fully constructed Orchestration Data Model (ODM) and performs validation to ensure governance integrity, contributor clarity, and CI enforceability.

The validator checks for:

* **Duplicate Configuration**: Ensures no two authorities configure the same POCO via `IEntityConfiguration<T>`
* **Mandate Conflicts**: Validates declared access intent against denial-first constraints
* **Lifecycle Flag Inconsistencies**: Detects misuse or overlap of lifecycle semantics across services
* **Cross-Authority Intent Resolution**: Confirms that all declared access is valid and scoped

Diagnostics emitted by this hook are contributor-facing and CI-ready. They include model type, authority name, mandate source, and validation context. Resolution guidance is out of scope for this document.

This hook is the final gate before orchestration proceeds to proxy traversal and runtime activation.

### **OnDelegateServiceAuthority**

### **ApplyModelConfiguration**

`ApplyModelConfiguration` is not a lifecycle hook in the orchestration context itself. Instead, it is a reflection-based extension on the abstract `ServiceAuthority`, activated during orchestration bootstrap. It scans the service abstraction’s assembly for types implementing `IEntityConfiguration`, applying model configuration declaratively and in isolation.

Each configuration type defines declarative setup for a governed model—indexes, constraints, lifecycle flags, and audit scope. These configurations are scoped to the authority’s modeling surface and applied without entangling domain abstractions.

This pattern avoids cyclic dependencies and preserves architectural separation. The service itself does not reference its abstraction directly. Configuration lives in the abstraction, and orchestration activates it externally.

Once model configuration is complete, any known mandates can be applied to the Service Authority. These mandates define denial-first constraints that restrict what other authorities may do with the governed models. They are applied declaratively and scoped to the authority's orchestration boundary.

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

  
