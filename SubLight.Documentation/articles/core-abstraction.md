<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See LICENSE.dual.md for full terms.
-->
# SubLight D.O.C. Core Abstractions

This document provides implementation guidance for the `SubLight.Abstractions` library—a stateless orchestration contract layer that unifies identity, caching, access intent, and telemetry across SQL, NoSQL, and in-memory stores.

## Purpose

SubLight’s core abstractions define orchestration-native primitives that enable stateless coordination across diverse storage backends. Rather than restating architectural goals, this layer formalizes how identity, caching, and access intent are expressed and consumed—through interfaces, envelopes, and lifecycle semantics.

These abstractions serve as the contract layer for:

* Intent-driven queries via LINQ-compatible surfaces
* Envelope-aware caching and consistency coordination
* Provider-neutral access across SQL, NoSQL, and in-memory stores
* Telemetry-safe orchestration without fragile integrations

---

## 🔧 Core Abstractions

These are the building blocks that implement the Enterprise Data Model within SubLight.

### Interfaces

* `IDataKey<T>`: Composable identity abstraction. Supports simple/composite keys, bulk resolution, and provider-neutral semantics.

* `IDataEnvelope<T>`: Metadata wrapper for versioning, timestamps, and cache hints. Enables envelope-aware caching and consistency coordination.

* `ISublightQueryProvider`: LINQ-compatible query provider that inherits `IQueryProvider` and expresses access intent.

* `IEnvelopeProvider`: Interface for providers to interpret envelope metadata and coordinate fallback, caching, and consistency.

* `IOrchestrationContext`: Ambient context for telemetry, access intent, and lifecycle flags.

* `IEnvelopeFactory`: Factory for constructing envelopes with versioning and lifecycle metadata.

### Abstract Classes

* `DataKeyBase`: Base implementation of `IDataKey`, supports equality, hash code, and composite key logic.
* `DataEnvelopeBase<T>`: Base implementation of `IDataEnvelope<T>`, encapsulates metadata and lifecycle flags.
* `OrchestrationContextBase`: Provides default telemetry and lifecycle semantics for orchestration flows.

### Enumerations

* `LifecycleSemantics`: Bitwise flags: `Persistent`, `Cachable`, `Ephemeral`, `Scoped`. Used for modeling orchestration-native lifecycles.
* `AccessIntent`: Enum for read/write/query/update/delete intent. Enables telemetry and provider optimization.
* `EnvelopeConsistency`: Enum for cache coordination: `Strong`, `Eventual`, `Fallback`, `None`.
* `TelemetryLevel`: Enum for tracing granularity: `None`, `Minimal`, `Verbose`, `Audit`.

## Governance Notes

* All interfaces must be extensible but sealed by intent—no fragile base classes.
* Abstract classes should be opt-in, not required for provider implementation.
* Enums should be flag-safe and documented with contributor-facing glossary links.
* Package must include dual-license headers, CLA enforcement hooks, and CODEOWNERS references to `docs-team`.

## Next Steps

To explore SubLight’s abstractions and contributor workflows:

* [Keys and Envelopes](keys-and-envelopes.md)
* [Bulk Operations](bulk-operations.md)
* [Extensibility Guidelines](extensibility.md)
* [Contributor Onboarding](onboarding.md)