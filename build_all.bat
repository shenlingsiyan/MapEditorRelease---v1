@echo off
rem Build all four projects (engines must be built before harness can spawn them)
cd /d "%~dp0"
for %%P in (MetaPlayer RMG_V1_1 FlexibleMapGen MapEditor) do (
  echo Building %%P ...
  dotnet build src\%%P -c Release --nologo -v q
  if errorlevel 1 ( echo Build failed: %%P & exit /b 1 )
)
echo All projects built.
