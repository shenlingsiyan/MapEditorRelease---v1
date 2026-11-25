@echo off
rem MapEditor launcher: build harness + start (auto opens browser)
rem NOTE: start this from a normal cmd session (not a detached/background process),
rem       otherwise child engine processes may fail to spawn.
cd /d "%~dp0"
if not exist src\MetaPlayer\bin\Release\net10.0\MetaPlayer.dll (
  echo First run: building all projects...
  call build_all.bat || ( pause & exit /b 1 )
)
dotnet build src\MapEditor -c Release --nologo -v q
if errorlevel 1 ( echo Build failed & pause & exit /b 1 )
start "MapEditor" dotnet run --project src\MapEditor -c Release --no-build
