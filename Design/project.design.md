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
  - Reference Entity: 
    - Is a table that contains static or semi-static data used to enforce consistency and reduce redundancy.
    - Can be referenced by 1 or more Data Entities
    - primary use case: 
      - look up table that has a key and value
    - example of use case: 
      - reference table that maps a .net enum
- use of database connection pools
  - a connection, reserved by a thread on demand and released back to the pool when no longer needed.
  - when the focus passes to another thread via asynchronous call a connection not in use will be allocated.
    - When a connection is not available and the connection limit has not been met.
      - a new connection will be created.
    - When a connection is not available and the connection limit has been met.
      - the process will wait for a free connection or create one if the current count drops below the limit.

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
