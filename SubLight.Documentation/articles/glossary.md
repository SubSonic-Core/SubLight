# 📘 SubLight Glossary

This glossary defines key concepts used throughout SubLight’s orchestration model. It’s designed to help contributors understand how entities behave, how providers interpret intent, and how orchestration flows remain stateless and declarative.

---

## 🔑 Core Concepts

| Term | Definition | 
| --- | --- | 
| **Distributed Object Coordinator** | SubLight’s core role: orchestrating object resolution, caching, and access control across SQL, NoSQL, and in-memory stores without coupling to backend logic. | 
| **DataKey** | A composable identifier that abstracts entity identity across providers. Supports simple, composite, and bulk resolution. | 
| **DataEnvelope** | A metadata wrapper that carries versioning, timestamps, and cache hints. Enables envelope-aware caching and consistency coordination. | 
| **AccessIntent** | A declarative signal of sensitivity and access boundaries. Enforced by providers and escalated via telemetry sinks. | 
| **TelemetrySink** | A component that records access events and escalates telemetry based on AccessIntent. Supports audit, trace, and compliance workflows. | 
| **Envelope Metadata** | Versioning, timestamps, and consistency hints used to coordinate cache resolution and fallback behavior. | 
| **Scoped Entity** | An entity that exists only during orchestration flow. Not persisted or cached. Used for runtime-only coordination. | 
| **LINQ Surface** | The query interface exposed by SubLight. Allows developers to express intent without coupling to backend-specific query languages. | 
| **Provider** | A backend-specific implementation that interprets entity declarations and resolves data. Can be SQL, NoSQL, OData, or cache-based. | 
| **Orchestration Flow** | The runtime context in which entities are resolved, cached, and coordinated. Stateless and declarative. | 

---

## 🧠 PersistenceIntent Flags

SubLight supports bitwise composition of lifecycle intent. These flags guide provider behavior and orchestration semantics.

| Flag | Meaning | 
| --- | --- | 
| `Persistent` | Backed by a durable store. Resolution must succeed against a provider. | 
| `Cachable` | May be resolved from envelope or cache. Often used for derived or transient-but-shareable data. | 
| `Ephemeral` | Exists only in memory. Not persisted or cached. Used for runtime-only entities. | 
| `Scoped` | Exists only during orchestration flow. Discarded after resolution. Ideal for access tokens, telemetry events, or projections. | 

### Examples

| Combination | Behavior | 
| --- | --- | 
| `Persistent | Cachable` | Cachable with durable fallback. | 
| `Ephemeral | Scoped` | Runtime-only, scoped to orchestration. | 
| `Cachable | Scoped` | Cached for duration of orchestration flow. | 
