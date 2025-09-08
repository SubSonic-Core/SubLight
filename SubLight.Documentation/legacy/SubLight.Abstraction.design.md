# SubLight.Abstraction

## Overview
SubLight.Abstraction is the architectural glue for the SubLight ecosystem. It defines contracts, interfaces, and shared types that other libraries depend on, enabling loose coupling, clear boundaries, and easy substitution of implementations.

## Responsibilities
- **Defines the common language**: All other libraries — Core, DataAccess, Domain, Extensions — communicate through the abstractions here, preventing tight coupling and allowing implementation swaps without breaking consumers.
- **Holds cross‑cutting contracts**: Interfaces for repositories, query objects, configuration providers, and service boundaries are defined here. These are implementation-agnostic, so DataAccess can implement them, Domain can consume them, and Core can extend them.
- **Enforces architectural boundaries**: By depending on abstractions, not concretions, circular dependencies are avoided.
- **Supports testability**: All dependencies are expressed as interfaces or simple records, making mocking and stubbing easy for tests.

## What It Owns
- **Contract interfaces**: Persistence, query translation, and query provider contracts consumed across libraries.
- **Shared base types**: Marker interfaces, base records, and common result types reused system-wide.
- **Common metadata**: Data envelope records and enums for carrying payload and key information between components.

## What It Does Not Own
- **Concrete implementations**: No database drivers, repositories, or network code.
- **Business rules**: No domain validations, invariants, or use-case logic.
- **Operational concerns**: No logging pipelines, telemetry exporters, or UI/presentation code.

## Implementation (current state)
- **ISubLightQueryProvider**
  - Extends `IQueryProvider`
  - Adds `Translate<TResult>(Expression, IQueryTranslator<TResult>)` for protocol-specific query translation
- **SubLightQueryable<TEntity>**
  - Implements `IQueryable<TEntity>`
  - Uses `ISubLightQueryProvider` for LINQ expression execution
- **DataKey, DataEnvelope, BulkDataEnvelope**
  - Records for entity keying and data transport
- **DataOperationType**
  - Enum for data operation semantics (e.g., Upsert)
- **IQueryResult, IQueryTranslator**
  - Abstractions for query result and translation

## Public Types (summary)
- `SubLight.ISubLightQueryProvider`
- `SubLight.Query.SubLightQueryable<TEntity>`
- `SubLight.Data.DataKey`
- `SubLight.Data.DataEnvelope`
- `SubLight.Data.BulkDataEnvelope`
- `SubLight.Data.DataOperationType`
- `SubLight.Query.IQueryResult`
- `SubLight.Query.IQueryTranslator`

## Dependencies
- No external dependencies in the .csproj
- All types are implementation-agnostic and safe for cross-library consumption

---

## Provider Compatibility

The abstraction layer is designed to support a wide range of data providers, including SQL, NoSQL, Redis, and MongoDB:

- **LINQ and Expression Support:** By extending `IQueryProvider` and using `IQueryable<TEntity>`, the abstractions enable LINQ-based querying, which is natively supported by most SQL and many NoSQL/document databases (e.g., MongoDB via LINQ providers).
- **Custom Query Translation:** The `Translate<TResult>` method allows each provider to implement its own translation logic, making it flexible for SQL (SQL syntax), MongoDB (BSON/JSON queries), Redis (key/value or set operations), and other NoSQL stores.
- **Generalized Data Transport:** The envelope and key records (`DataKey`, `DataEnvelope`, `BulkDataEnvelope`) are agnostic to storage type and can represent entities, keys, and operations for relational, document, or key/value stores.
- **Bulk Operations:** `BulkDataEnvelope` supports batch operations, which are common in all major data stores.
- **Result and Translator Abstractions:** `IQueryResult` and `IQueryTranslator` are generic and do not prescribe a specific data format or protocol, allowing each provider to define its own result and translation logic.

**Summary:**  
The abstraction layer is provider-agnostic and supports SQL, NoSQL, Redis, and MongoDB providers. Each provider can implement the contracts according to its data model and query capabilities, ensuring broad compatibility and extensibility across different storage technologies.

