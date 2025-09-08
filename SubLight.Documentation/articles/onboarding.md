# Contributor Onboarding

Welcome to SubLight—a stateless, cache-aware orchestration layer for distributed data access. This guide will help you get up and running quickly, understand the system’s core abstractions, and contribute with confidence.

## 💡 Why SubLight?

SubLight solves the hard parts of backend architecture—so contributors don’t have to. It orchestrates caching, consistency, and provider-neutral queries through a LINQ-driven abstraction.

Instead of reimplementing cache logic, coupling to fragile ORMs, or manually coordinating bulk operations, SubLight provides:

- A unified LINQ query surface  
- Envelope-aware caching and resolution  
- Stateless orchestration across providers  
- Extensible interfaces with clean separation of concerns

For a deeper dive into the system’s design, see [Architecture](architecture.md).

## 🧱 Deployment Context

SubLight runs inside containerized or load-balanced service instances. Each instance:

- Operates independently and statelessly  
- Shares cache state via distributed providers (e.g. Redis, HybridCache)  
- Resolves queries via LINQ and provider contracts  
- Requires no central coordinator or shared memory

Whether deployed via Docker, Kubernetes, or IIS, SubLight ensures consistent, predictable behavior across instances.

> ⚠️ Note: Entities must explicitly declare themselves as cacheable and persistent to participate in envelope resolution. This prevents accidental caching and ensures providers coordinate only when needed.


## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/SubSonic-Core/SubLight.git
git submodule update --init --recursive
```

### 2. Build the Documentation
```bash
cd SubLight.Documentation/commands
generate-docs.bat
```
To preview locally