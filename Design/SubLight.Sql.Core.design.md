# SubLight.Sql.Core
## Overview
  SubLight.Sql.Core is a foundational library that provides core functionalities for interacting with SQL databases. It serves as a base for specific SQL database providers, implementing common patterns and practices for data access, connection management, and query execution. This library abstracts the complexities of SQL interactions, allowing higher-level components to operate without needing to understand the intricacies of SQL syntax or database-specific behaviors.
  ## Responsibilities
  - Implements core data access patterns such as repositories and unit of work.
  - Provides abstractions for executing SQL commands
## Implementation
- [SqlQueryResult](./Sql/SqlQueryResult.design.md)
- [SqlQueryTranslatorBase](./Sql/SqlQueryTranslatorBase.design.md)
	
## Dependencies
- [SubLight.Abstraction](./SubLight.Abstraction.design.md)
- System.Data.Common