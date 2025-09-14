<!--
Copyright © 2025 Kenneth Carter

This documentation is part of the Distributed Object Coordinator (DOC Library) and is licensed under the project's dual-license model:
- Free for educational, research, personal, or nonprofit use
- Commercial use requires a paid license

See [LICENSE.md](https://github.com/SubSonic-Core/SubLight/blob/main/LICENSE.md) for full terms.

Last updated: 9/13/2025 6:31 PM
-->
# SubLight Documentation

This project hosts architectural notes, contributor onboarding, and API reference docs for SubLight.

# Prerequisites
- [.NET SDK](https://dotnet.microsoft.com/download) (version 6.0 or later)
- DocFX CLI tool installed globally:
  ```bash
  dotnet tool install -g docfx
  ```

## Build Docs

To generate the documentation site:

```bash
msbuild SubLight.Documentation.csproj /t:GenerateDocs
```

Or use Task Runner Explorer in Visual Studio to run the `GenerateDocs` target.

# Preview Locally:
```bash
docfx serve _site
```

# Structure
- `articles/`: Architectural notes and contributor onboarding guides.
- `api/`: API reference documentation.
- docfx.json: DocFX configuration file.