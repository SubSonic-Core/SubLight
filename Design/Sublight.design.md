# Mission
``` text
To be the most performant and efficient data access ORM to support the data demands required in micro cloud distributed system. 
```
## Terms
  ### Entity

  An **Entity** represents a uniquely identifiable domain object whose identity is defined by a primary key rather than by its attribute values. Entities are persisted and retrieved through the ORM layer, and their lifecycle is managed explicitly by the application.
  
  **Core Characteristics:**
  - **Identity:**  
    - Each entity has a unique identifier (e.g., primary key) that remains constant for the lifetime of the entity.
  - **Equality:**  
    - Two entity instances are considered equal if and only if they share the same identifier.
  - **Persistence:**  
    - Entities are stored in and retrieved from a backing data source via the ORM.
    - The ORM does not perform automatic change tracking; all updates must be explicitly persisted.
  - **Caching:**  
    - No implicit caching is performed by the ORM.  
    - At model creation, an optional `IDataRetriever<TEntity>` can be registered to provide custom retrieval logic (including caching, batching, or alternative data sources).
  - **Retriever Integration:**  
    - The Query Builder is aware of the configured `IDataRetriever<TEntity>` and will:
      1. Attempt to retrieve the entity via the retriever.
      2. If not found, query the database.
      3. Optionally allow the retriever to store the freshly loaded entity.
  - **Loading Strategy:**  
    - Related entities are lazy‑loaded by default; eager loading is opt‑in per query.
  - **Concurrency & Validation:**  
    - Concurrency control and validation are handled externally in the domain or application layer.
  
  **Example:**
  ```csharp
  using System;
  using System.Collections.Generic;
  
  public class OtlpLogEntity
  {
      // Primary key for persistence
      public Guid Id { get; set; }
  
      // OpenTelemetry log fields
      public DateTimeOffset Timestamp { get; set; }
      public string SeverityText { get; set; }
      public int SeverityNumber { get; set; }
      public string Body { get; set; }
  
      // Resource and scope attributes
      public Dictionary<string, string> ResourceAttributes { get; set; } = new();
      public Dictionary<string, string> ScopeAttributes { get; set; } = new();
  
      // Trace context
      public string TraceId { get; set; }
      public string SpanId { get; set; }
      public byte TraceFlags { get; set; }
  }
  
  // Example usage
  var log = new OtlpLogEntity
  {
      Id = Guid.NewGuid(),
      Timestamp = DateTimeOffset.UtcNow,
      SeverityText = "INFO",
      SeverityNumber = 9,
      Body = "Exporter started successfully",
      TraceId = "4bf92f3577b34da6a3ce929d0e0e4736",
      SpanId = "00f067aa0ba902b7",
      TraceFlags = 1
  };
  
  repository.Insert(log); // Explicit persistence
  ```
  ### Reference Entity
  A ReferenceEntity represents reusable, non-volatile data structures that support normalization, validation, and metadata-driven modeling. These entities typically contain static or semi-static datasets—such as countries, currencies, or status codes—that are referenced across multiple domain models.

  ReferenceEntities differ from regular Entities in that they are often read-heavy, centrally managed, and designed for reuse. They may support metadata, relationships to other ReferenceEntities, and localization.

  - Enumerated data sets
  - Dynamic fields and metadata
  - Relationships to other ReferenceEntities
  - Versioning and auditability
  - Localization and hierarchical structures

  #### ORM Behavior
  
  The `Reference Entity` is persisted and retrieved through the ORM with **no built‑in caching or change tracking**. Every retrieval operation queries the underlying data source directly **unless** a custom retrieval strategy is provided.
  
  **Key behaviors:**
  
  - **No Implicit Caching**  
    - By default, all queries hit the underlying data source.  
    - The ORM never stores or reuses entity instances between calls.
  
  - **Retriever‑Aware Query Builder**  
    - At model creation, a custom `IDataRetriever<TEntity>` can be registered.  
    - The Query Builder in the core library is aware of this retriever and will:  
      1. Attempt to resolve the entity via the retriever.  
      2. If the retriever returns `null`/`default`, fall back to executing the database query.  
      3. Optionally allow the retriever to populate itself with the freshly loaded entity.
  
  - **Stateless Persistence**  
    - No change tracking is performed; updates must be explicitly persisted.
  
  - **Loading Strategy**  
    - Related entities are lazy‑loaded by default; eager loading is opt‑in per query.
  
  - **Concurrency & Validation**  
    - Both are handled externally in the domain or application layer.
  
  **Example:**
  ```csharp
  // Model configuration
  modelBuilder.Entity<ReferenceEntity>()
      .UseDataRetriever(new CachedReferenceRetriever());
  
  // IDataRetriever<TEntity> contract
  public interface IDataRetriever<TEntity>
  {
      TEntity Retrieve(object key);
      void Store(object key, TEntity entity); // optional
  }
  
  // Query Builder flow (simplified)
  public TEntity GetById<TEntity>(object key)
  {
      var retriever = _retrieverRegistry.Get<TEntity>();
      var entity = retriever?.Retrieve(key);
      if (entity != null) return entity;
  
      entity = _database.Query<TEntity>().WhereId(key).SingleOrDefault();
      retriever?.Store(key, entity);
      return entity;
  }
  ```

  #### Relationship Types
  ReferenceEntities typically participate in many-to-one relationships, serving as lookup tables for domain entities. However, in advanced scenarios, they may also facilitate one-to-one mappings between two domain entities—especially when a shared classification or metadata is required to enforce consistency.

  #### Examples include
  - Country, Currency, StatusCode
  - Role, PermissionType, DocumentCategory

  #### Code Examples:
  - a workflow status usualy with pending, in progress, complete.
      ``` C#
        public enum WorkFlowStatus
        {
          UNKNOWN = 0,
          Pending = 1,
          InProgress = 2,
          Complete = 3
        }
      ```
    would map to a table:
      ``` SQL
        CREATE TABLE dbo.WorkFlowStatus
        (
          [WorkFlowStatusId] INT PRIMARY KEY,
          [Name] VARCHAR(50) NOT NULL,
          [Description] VARCHAR(MAX) NULL
        )
      ```
# Features
## 🧩 SubLight.Core vs Provider Responsibilities

| Feature Category | Implement in `SubLight.Core` | Implement in Provider |
|------------------|------------------------------|-----------------------|
| **Core Connection Lifecycle** | Abstract connection handling via `DbConnection` base class; open/close orchestration; disposal patterns | Actual connection creation and pooling behavior (provider’s `DbConnection` subclass) |
| **Command Execution** | Unified API for executing commands (`ExecuteReader`, `ExecuteScalar`, `ExecuteNonQuery`) against `DbCommand` | Provider‑specific SQL dialect quirks, multiple result set support (e.g., MARS) |
| **Data Reading** | Wrap `DbDataReader` in a provider‑agnostic reader interface; map to common CLR types | Provider‑specific type conversions (e.g., PostgreSQL `timestamp with time zone` → `DateTimeOffset`) |
| **Parameters** | Abstract parameter binding API; enforce consistent naming and ordering in Core | Parameter prefix rules (`@`, `:`, `?`), native type mapping, size/precision handling |
| **Transactions** | Transaction orchestration via `DbTransaction` base class; ambient transaction hooks | Distributed transaction support (MSDTC, XA) and provider‑specific isolation levels |
| **Schema Access** | Provide a normalized schema metadata model in Core | Implement `GetSchema()` calls and translate provider’s schema collections into Core’s model |
| **DataAdapter / DataSet** | If supported, wrap fill/update in a provider‑agnostic adapter | Provider’s actual `DbDataAdapter` subclass and batch update logic |
| **Async APIs** | Expose async methods in Core (`OpenAsync`, `ExecuteReaderAsync`) | Provider’s async implementation and cancellation token support |
| **Error Handling** | Normalize exceptions to Core’s error model (wrap `DbException`) | Populate provider‑specific error codes, SQL state, and diagnostic info |
| **Provider Factory** | Use `DbProviderFactory` in Core to create connections/commands generically | Register provider factory and invariant name; ensure it’s discoverable |


# Architecture
## [SubLight.Core](SubLight.Core.design.md)
## [SubLight.Abstraction](SubLight.Abstraction.design.md)  
## SubLight.Providers
SubLight Providers, define how to talk to the actual backend, including quirks, type mappings and provider specific features

The following resposibilites apply to all providers:
- Using migration up/down strategy generate provider specific change scripts.
- parameterized queries are optimized to be efficient and performant with the least amount of overhead allowed.
- IQueryResult and IQueryTranslator are implemented to support the provider specific dialect.
- Sql Providers will have a Sql Core that implements the common sql features across all sql providers.
    - ### [SubLight.Sql.Abstractions](SubLight.Sql.Abstractions.design.md)
- list of providers:
    - ### [SubLight.Providers.SqlServer](SubLight.Providers.SqlServer.design.md)
