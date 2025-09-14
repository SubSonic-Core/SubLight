<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight.Providers.SqlServer
## Overview
  SubLight.Providers.SqlServer is a specialized library that implements the data access layer for SQL Server databases. It leverages the contracts and abstractions defined in SubLight.Abstraction to provide a robust, efficient, and scalable way to interact with SQL Server, handling everything from connection management to query execution.
  ## Responsibilities
  - Implements the translation of LINQ expressions to SQL Server-specific SQL queries.
  - Provides concrete IQueryTranslator implementations for SQL Server.
  - Handles SQL syntax, parameterization, and optimizations specific to SQL Server. 
  ## What It Owns
  - **SQL Server-specific implementations**: Concrete classes for repositories, query builders, and unit of work patterns that interact with SQL Server.
  - **Connection and transaction management**: Logic for handling connections, transactions, and error scenarios specific to SQL Server.
  - **Database migration tools**: Utilities for managing schema changes and applying migrations in a SQL Server context.
  ## What It Does Not Own
  - **Core domain logic**: No business rules, validations, or domain-specific logic.
  - **Cross-cutting concerns**: No logging pipelines, telemetry exporters, or UI/presentation code.
  - **Other database providers**: No implementations for databases other than SQL Server.
  ## Benefits
  - **Optimized performance**: Tailored implementations that leverage SQL Server's strengths for efficient data access.
  - **Seamless integration**: Works seamlessly with the abstractions defined in SubLight.Abstraction, allowing easy substitution with other providers if needed.
  - **Robust error handling**: Comprehensive management of SQL Server-specific errors and exceptions.
  ## Dependencies
  - [SubLight.Abstraction](./SubLight.Abstraction.design.md)
  - Microsoft.Data.SqlClient
