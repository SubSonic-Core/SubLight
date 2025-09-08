@echo off
echo Generating documentation with DocFX...
cd ..
if exist docfx.json (
    docfx docfx.json
) else (
    echo docfx.json not found. Make sure you're in the correct directory.
)
pause
