<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# 📘 SubLight Glossary

This glossary defines key terms used throughout SubLight’s orchestration model. It is strictly limited to declarative definitions—what each concept *is*, not how it behaves. Contributors can use this glossary to understand terminology used in entity lifecycles, access semantics, and orchestration boundaries. Behavioral mechanics (like telemetry escalation or fallback coordination) are documented separately in onboarding and implementation guides.

---

## 🔑 Core Concepts

| Term | Definition | 
| --- | --- | 
| **Distributed Object Coordinator** | SubLight’s orchestration root. Coordinates object resolution, caching, and access control across SQL, NoSQL, and in-memory stores—without coupling to backend logic. | 
| **DataKey** | A composable identifier that abstracts entity identity across providers. Supports simple, composite, and bulk resolution. | 
| **DataEnvelope** | A metadata wrapper that carries versioning, timestamps, and cache hints. Enables envelope-aware caching and consistency coordination. | 
| **AccessIntent** | A declarative signal that expresses sensitivity, visibility, and access boundaries. Interpreted by providers to enforce access control and escalated via telemetry sinks for audit and traceability. Think of it like a doorman’s posture: <br>• **Public** – Open access, no questions asked. <br>• **Restricted** – On alert, inspecting baggage, logging entries. <br>• **Forbidden** – “You shall not pass.” Access blocked, escalated, or redirected. | 
| **TelemetrySink** | A component that records access events and escalates telemetry based on AccessIntent. Think of it as the security camera and logbook behind the doorman—capturing who came in, what they carried, and whether they triggered alerts. Supports audit, trace, and compliance workflows. | 
| **Envelope Metadata** | A metadata wrapper that includes versioning, timestamps, consistency hints, fallback coordination signals, and trace directives. Used to guide envelope-aware caching, resolution fallback, telemetry escalation, and provider behavior across orchestration flow. | 
| **Scoped Entity** | An entity that exists only during orchestration flow. Not persisted or cached. Used for runtime-only coordination. Like a guest pass that expires when the event ends—valid only for the duration of the orchestration. | 
| **Query Surface** | The orchestration-facing layer where contributors express declarative queries for entity resolution. It abstracts away backend-specific query languages and focuses on intent clarity. Distinct from the `Resolution Surface`, which providers use to interpret and fulfill those queries. | 
| **Resolution Surface** | The provider-facing layer that interprets declarative queries from the `Query Surface`. Responsible for resolving entities, applying modifiers, and enforcing provider-specific logic. | 
| **Entity Projection** | A derived entity composed from one or more source entities. Often ephemeral and cacheable. Used to express runtime-only views or coordination artifacts. | 
| **Fallback Strategy** | A declarative rule that guides resolution when the primary provider fails. May include alternate providers, default values, or escalation paths. | 

---

## 🧠 Entity Declaration Semantics

SubLight expresses entity lifecycle expectations through a combination of declaration type and orchestration modifiers.

| Declaration | Meaning | 
| --- | --- | 
| `Durable` | Backed by a persistent store. Resolution must succeed against a provider. | 
| `Ephemeral` | Exists only in memory. Not persisted or cached. Used for runtime-only entities. | 

### Orchestration Modifiers

| Modifier | Behavior | 
| --- | --- | 
| `Cacheable` | May be resolved from envelope or cache. Often used for derived or transient-but-shareable data. | 
| `Scoped` | The entity lives only while the orchestration is running. It’s tied to the orchestration’s internal context and disappears when that context ends. It’s never saved or reused. Think of it like a temporary pass—valid only during the current request. | 
| `Transient` | Passed into orchestration like a method parameter. It can be durable or in-memory, but it’s thrown away as soon as the orchestration finishes. Think of it like a short-lived value on the stack—used once, then gone. | 