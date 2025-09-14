<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight.Core
## Overview
SubLight.Core is the heart of the architecture. It contains the fundamental building blocks, base classes, and shared utilities that other libraries extend and build upon. It provides a solid foundation for domain logic, data access, and application services.
## Responsibilities
- Owns the SubLightQueryProvider implementation.
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
## Defined Roles of discrete components
### Role of SubLightQueryProvider
- implements IQueryProvider so it can:
	- Accept LINQ expression trees.
	- Translate them into SubLights internal query representation.
	- Execute against the underlying database via the provider.
- Stateless — no open connections until execution time.
- Provider-agnostic — delagates actual SQL generation and execution to the active provider. (e.g., Sql Server, PostgreSQL)
- Extensible - can be wrapped with additional behaviors (logging, caching, profiling) without breaking the core contract.
- Is aware of IDataRetriever defined on the MetaModel to optimize entity retrieval and caching.
#### Suggested Interface
``` C#
public interface ISubLightQueryProvider : IQueryProvider
{
	// Access to the underlying provider for execution
	ISubLightDataProvider DataProvider { get; }
	
	// Provider-specific query translation
	string Translate(IQueryTranslator translator);
}
```
## Dependencies
- [SubLight.Abstraction](./SubLight.Abstraction.design.md)