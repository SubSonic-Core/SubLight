# Mission
``` text
To be the most performant and efficient data access ORM to support the data demands required in micro service architecture. 
```
- entity caching will be managed based on the needs of each entity.
  - In Memory Change Tracking will not be implemented in this ORM
    - It is wasteful to track changes on all entities from cradle to grave and results potential stale data across multiple systems.    
- use of database connection pools
  - a connection, reserved by a thread on demand and released back to the pool when no longer needed.
  - when the focus passes to another thread via asynchronous call a connection not in use will be allocated.
    - When a connection is not available and the connection limit has not been met.
      - a new connection will be created.
    - When a connection is not available and the connection limit has been met.
      - the process will wait for a free connection or create one if the current count drops below the limit.

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
# SubLight
- ORM core functionality
  - Data Model Creation
  - Expression Query Building
- Dependencies
  - SubLight.Abstraction
# SubLight.Abstraction
- abstraction layer where all the interfaces and common implementation between the main library and the providers
- Dependencies
  - unknown
# SubLight.Providers
- SubLight providers are responsible for all implementation for interacting with a database
  - Database Change Script creation
    - optimized for bulk data manipulation
  - Expression Query Builder Translation
  
  ## SubLight.Providers.SqlServer
  - Schema Generation
    - Entities
      - generate table to store data
      - generate user defined table type to support bulk data streaming
    - Reference Entities
      - generate table to store data
  - Dependencies
    - SubLight.Abstraction
    - Microsoft.Data.SqlClient
