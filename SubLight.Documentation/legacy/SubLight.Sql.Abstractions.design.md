<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight.Sql.Core
## Overview
  SubLight.Sql.Abstractions is a foundational library within the SubLight ecosystem that provides essential abstractions and interfaces for interacting with SQL databases. It is designed to facilitate database operations in a provider-agnostic manner, allowing developers to work with various SQL database systems seamlessly.
  ## Responsibilities
  - Provides common sql abstractions for working with sql databases.
## Implementation
- [SqlQueryResult](./Sql/SqlQueryResult.design.md)
- [SqlQueryTranslatorBase](./Sql/SqlQueryTranslatorBase.design.md)
	
## Dependencies
- [SubLight.Abstraction](./SubLight.Abstraction.design.md)
- System.Data.Common