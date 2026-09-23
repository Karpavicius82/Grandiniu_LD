@echo off
setlocal DisableDelayedExpansion
rem Start the graphical Scilab student interface; no admin rights or server.
set "LD_SCILAB_GUI="
if defined SCILAB_BIN if exist "%SCILAB_BIN%" for %%I in ("%SCILAB_BIN%") do if exist "%%~dpIWScilex.exe" set "LD_SCILAB_GUI=%%~dpIWScilex.exe"
if defined LD_SCILAB_GUI goto launch
for /d %%D in ("%ProgramFiles%\scilab-2026.1.0" "%ProgramFiles%\scilab-*" "%LOCALAPPDATA%\Programs\scilab-*") do if exist "%%~D\bin\WScilex.exe" set "LD_SCILAB_GUI=%%~D\bin\WScilex.exe"
if defined LD_SCILAB_GUI goto launch
echo Scilab GUI nerastas. Reikalingas Scilab 2026.1.0, Windows x64.
echo Atverkite STENDAS.sce grafiniame Scilab lange ir pasirinkite Vykdyti.
echo Studentui nereikia paleisti bin\ldcheck.exe arba bin\mokytojas.exe.
pause
exit /b 1
:launch
if not exist "%~dp0bin\ldcore.dll" (
  echo Truksta bin\ldcore.dll. Isskleiskite visa Windows paketa.
  pause
  exit /b 1
)
start "Grandiniu laboratoriniai darbai" "%LD_SCILAB_GUI%" -f "%~dp0STENDAS.sce"
exit /b 0
