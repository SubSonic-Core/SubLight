<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight Extensibility Guidelines

## Purpose
Defines how external providers, contributors, and orchestration surfaces can extend SubLight safely and predictably.

---

## Provider Interface Contracts

* `ISubLightQueryProvider` — Accepts expression trees and executes them against local context  
* `IEnvelopeAuthority` — Governs metadata resolution and change tracking  
* `ITelemetrySink` — Streams access events and escalation triggers

---

## Expression Delegation Patterns

* How SubLight serializes LINQ segments for gRPC transport  
* Validating and executing expression trees safely  
* Mapping upstream query intent to local provider context

---

## Compliance Hooks

* AccessIntent enforcement  
* Telemetry escalation  
* Mutation boundaries and audit triggers

---

## Contributor Extension Points

* Adding new providers  
* Extending envelope metadata  
* Registering telemetry sinks  
* Declaring new orchestration behaviors

---

## Testing and Validation

* Provider compliance checklist  
* Expression tree safety tests  
* Envelope resolution scenarios  
* Telemetry sink verification

---

## Proxy Generation and Navigation

### 🧠 Contributor Notes

* Navigation properties must be declared explicitly virtual in the proxy surface.
* Cacheability is opt-in—ambient resolution is never assumed.
* Providers interpret navigation flags independently, but orchestration remains consistent.
* Envelope metadata may include relationship freshness hints (e.g. `LastResolved`, `Version`, `ConsistencyLevel`).

---