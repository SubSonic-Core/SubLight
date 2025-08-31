# Mission
``` text
To be the most performant and efficient data access ORM to support the data demands required in micro service architecture. 
```
- entity caching will be managed based on the needs of each entity.
  - In Memory Change Tracking will not be implemented in this ORM
    - It is wasteful to track changes on all entities from cradle to grave and results potential stale data across multiple systems.
  - Reference Entities, is a table that contains static or semi-static data used to enforce consistency and reduce redundancy.
    - caching this data will reduce the cost of hitting the database
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
  - Dependencies
  - SubLight.Abstraction
  ## SqlServer
