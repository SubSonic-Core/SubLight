<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# 📊 SubLight in Context: Comparative Architecture Overview

This document helps contributors understand how SubLight’s orchestration philosophy aligns with, diverges from, and surpasses existing coordination frameworks. It’s a reference point for architectural clarity, contributor onboarding, and long-term maintainability.

---

## ✅ Shared Foundations

SubLight shares several core goals with leading orchestration frameworks:

- **Distributed Coordination**  
  Enables orchestration across services, providers, and data boundaries.

- **Resilience & Retry Semantics**  
  Supports scoped retries and lifecycle-aware fault handling.

- **Composable Interfaces**  
  Encourages expressive, modular orchestration flows.

- **Provider Abstraction**  
  Decouples orchestration logic from execution environments.

---

## 🔍 Architectural Divergences

SubLight rethinks orchestration from first principles, with deliberate departures from conventional frameworks:

| Dimension | SubLight | Conventional Frameworks |
|----------|----------|--------------------------|
| **Lifecycle Modeling** | Bitwise enums (`Persistent`, `Scoped`, etc.) | Implicit via retries or state machines |
| **Contributor Onboarding** | Glossary-first, markdown-native | SDK-heavy, config-driven, or GUI-based |
| **Governance & Licensing** | CLA enforcement, code ownership, dual-license clarity | Often externalized or neglected |
| **Telemetry & Auditability** | Escalation-aware, compliance-native | Logging plugins or external observability |
| **Naming & Category Definition** | Iterative, philosophical refinement | Convention-based or domain-specific |
| **Traversal Semantics** | Roslyn-based proxy generation | Runtime introspection or manual wiring |

---

## 🚀 Groundbreaking Innovations

SubLight introduces architectural primitives that redefine orchestration:

- **Orchestration-Aware Property Traversal**  
  Compile-time safe, provider-neutral navigation via Roslyn proxies.

- **Lifecycle as a First-Class Concept**  
  Lifecycle flags guide caching, persistence, and scope—architecturally, not procedurally.

- **Governance-Embedded Architecture**  
  CLA automation, contributor rights, and licensing clarity are part of the system’s DNA.

- **Pedagogical Onboarding**  
  Glossary-first documentation teaches orchestration reasoning before implementation.

- **Separation of Concepts vs Abstractions**  
  Clean split between foundational ideas and implementation details.

---

## 🧠 Why It Matters

SubLight isn’t just an orchestration engine—it’s a reference architecture for **compliant, maintainable, and contributor-friendly distributed systems**. It empowers teams to reason clearly, onboard confidently, and extend safely.