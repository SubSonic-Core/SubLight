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