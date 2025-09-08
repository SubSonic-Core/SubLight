serve-docs.bat
@echo off
echo Serving documentation locally...
cd ..
if exist docfx.json (
	docfx docfx.json --serve
) else (
	echo docfx.json not found. Make sure you're in the correct directory.
)
pause
