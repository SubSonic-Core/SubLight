# SubLight.Abstraction
  ## Overview
  SubLight.Abstraction is the glue of the architecture. It defines the contracts, interfaces, and shared concepts that other libraries rely on, enabling loose coupling, clear boundaries, and easy substitution of implementations.
  ## Responsibilities
  - **Defines the common language**
    All other libraries — Core, DataAccess, Domain, Extensions — speak through the abstractions here. This prevents tight coupling and lets you swap implementations without breaking the rest of the system.
  - **Holds cross‑cutting contracts**
    Interfaces for repositories, query objects, configuration providers, and service boundaries live here. They’re implementation‑agnostic, so DataAccess can implement them, Domain can consume them, and Core can extend them.
  - **Enforces architectural boundaries** Because everything depends on abstractions, not concretions, you avoid circular dependencies. For example:
    - Domain → Abstraction → DataAccess (implementation)
    - Core → Abstraction → Extensions (optional add‑ons)
  - **Supports testability**
    With all dependencies expressed as interfaces, you can easily mock or stub them in Tests without pulling in real database or infrastructure code.
  ## What It Owns
  - **Contract interfaces**: Persistence, configuration, and service contracts consumed across libraries.
  - **Shared base types**: Marker interfaces, base records, and common result types reused system-wide.
  - **Common metadata**: Enums, option models, identifiers, and shared error or status types.
  ## What It Does Not Own
  - **Concrete implementations**: No database drivers, repositories, or network code.
  - **Business rules**: No domain validations, invariants, or use-case logic.
  - **Operational concerns**: No logging pipelines, telemetry exporters, or UI/presentation code.
  ## Benefits
  - **Loose coupling**: Changes in implementations do not cascade into consumers.
  - **Swap-ability**: Implementations can be replaced without breaking public contracts.
  - **Clarity**: Clear separation between what services promise and how they are fulfilled.
  ## Dependencies
  - none at this time
