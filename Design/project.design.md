# Mission
``` text
To be the most performant and efficient data access ORM to support the data demands required in micro service architecture. 
```
- entity caching will be managed based on the needs of each entity.
  - In Memory Change Tracking will not be implemented in this ORM
    - It is wasteful to track changes on all entities from cradle to grave and results potential stale data across multiple systems.
- Terms:
  - Data Entity:
    - Is a table that contains data that can be selected, updated and deleted        
- use of database connection pools
  - a connection, reserved by a thread on demand and released back to the pool when no longer needed.
  - when the focus passes to another thread via asynchronous call a connection not in use will be allocated.
    - When a connection is not available and the connection limit has not been met.
      - a new connection will be created.
    - When a connection is not available and the connection limit has been met.
      - the process will wait for a free connection or create one if the current count drops below the limit.

  ## Terms

    ### Reference Entity
    A ReferenceEntity represents reusable, non-volatile data structures that support normalization, validation, and metadata-driven modeling. These entities typically contain static or semi-static datasets—such as countries, currencies, or status codes—that are referenced across multiple domain models.
  
    ReferenceEntities differ from regular Entities in that they are often read-heavy, centrally managed, and designed for reuse. They may support metadata, relationships to other ReferenceEntities, and localization.

    - Enumerated data sets
    - Dynamic fields and metadata
    - Relationships to other ReferenceEntities
    - Versioning and auditability
    - Localization and hierarchical structures

    #### ORM Behavior
    - Caching will be configured at model creation.
      - explicit behavior is no caching. 
      - can be configured to use retriever that implements a IDataRetriever\<TEntity\> interface
      - when cached the data can expire and be removed from memory
        - though the retriever should stamp when the data is used and extend the period of validity
        - generaly refernce data should be read only.
 
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
- Dependencies
  - SubLight.Abstraction
# SubLight.Abstraction
- abstraction layer where all the interfaces and common implementation between the main library and the providers
- Dependencies
  - unknown
# SubLight.Providers
- SubLight providers are responsible for all implementation for interacting with a database
  - script generation
    - schema change scripts
    - expression tree that will translate expressions to a script that can be passed through to the database implemented by the provider
  
  ## SubLight.Providers.SqlServer
  - Dependencies
    - SubLight.Abstraction
    - Microsoft.Data.SqlClient
