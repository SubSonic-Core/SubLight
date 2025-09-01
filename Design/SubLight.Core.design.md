# SubLight.Core
## Overview
  SubLight.Core is the heart of the architecture. It contains the fundamental building blocks, base classes, and shared utilities that other libraries extend and build upon. It provides a solid foundation for domain logic, data access, and application services.
  ## Responsibilities
  - Owns the generic QueryBuilder implementation.
  -	Handles query composition, entity/retriever integration, and expression tree construction.
  - Exposes provider-agnostic query APIs (e.g., Where, Select, OrderBy, etc.).
  ## What It Owns
  - **Core domain abstractions**: Base classes and interfaces for entities, value objects, aggregates, and repositories.
  - **Shared utilities**: Helpers for common tasks like validation, mapping, error handling, and logging.
  - **Extension points**: Events, hooks, and middleware for customizing core workflows.
  ## What It Does Not Own
  - **Concrete implementations**: No specific database drivers, repositories, or network code.
  - **Business rules**: No domain validations, invariants, or use-case logic.
  - **Operational concerns**: No logging pipelines, telemetry exporters, or UI/presentation code.
  ## Benefits
  - **Consistency**: A unified approach to modeling domain concepts across the system.
  - **Reusability**: Shared base classes and utilities reduce duplication and speed up development.
  - **Extensibility**: Clear extension points allow customization without modifying core code.
  ## Dependencies
  - [SubLight.Abstraction](./SubLight.Abstraction.design.md)