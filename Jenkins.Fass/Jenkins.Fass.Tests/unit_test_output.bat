@echo off
setlocal EnableDelayedExpansion

if [%1]==[/?] goto :help

:: root is the folder containing this script (without trailing backslash)
set root=%~dp0
echo root: %root%
set projectroot=%root:~0,-19%
echo projectroot: %projectroot%


:: put xunit binaries into a folder without versioning in the name
set xdir=^"%root%\bin\debug\xunit\^"

:: set defaults
set resultCode=0
set outputPath=^"%root%bin\debug\xunit\xunit-results.xml^"
set configuration=Debug
set failOnError=0

:: process command line
if not [%1]==[] if not [%1]==[-] set outputPath=%1
if not [%2]==[] if not [%2]==[-] set configuration=%2
if not [%3]==[] if not [%3]==[-] set failOnError=%3

:: report configuration
echo output-path:   %outputPath%
echo configuration: %configuration%
echo fail-on-error: %failOnError%
echo xdir: %xdir%

:: clear out old bin path
if exist "%"xdir"%" rmdir "%"xdir"%" /s /q
mkdir "%"xdir"%"



:: Copy the current xunit console runner to the bin folder
for /f "tokens=*" %%a in ('dir /b /s /a:d "%projectroot%\packages\xunit.runner.console.*"') do (
 copy "%%a\tools\*" "%xdir%" >NUL
)

:: Copy the current xunit exeuction library for .net 4.5 to the bin folder
for /f "tokens=*" %%a in ('dir /b /s /a:d "%projectroot%\packages\xunit.extensibility.execution.*"') do (
  copy "%%a\lib\net452\*" "%xdir%" >NUL
)

:: Discover test projects
set testAssemblies=
for /f "tokens=*" %%a in ('dir /b /s /a:d "%root%\*.Tests"') do (
  :: copy the execution library into each test library output folder
  copy "%xdir%\xunit.execution.desktop.dll" "%%a\bin\%configuration%\" >NUL

  :: add this assembly to the list of assemblies (delayed expansion)
  set testAssembly=^"%%a\bin\%configuration%\%%~nxa.dll^"
  if [!testAssemblies!]==[] (
    set testAssemblies=!testAssembly!
  ) else (
    set testAssemblies=!testAssemblies! !testAssembly!
  )
)

:: run the xunit console runner
echo on
set testAssemblies="%root%\bin\Debug\Jenkins.Fass.Tests.dll"
"%xdir%\xunit.console.exe" %testAssemblies% -xml %outputPath% -parallel all -class "Jenkins.Fass.Tests.UnitTestExamples"


@echo off
if /i %failOnError% neq 0 (
  set resultCode=%ERRORLEVEL%
)

exit /b %resultCode%

:help
echo USAGE: %~xn0 [output-path] [configuration] [fail-on-error]
echo.
echo Arguments are optional, supply - to use default value.
echo.
echo output-path: path to output file (v2 xml format)
echo configuration: build configuration to test (release, debug, ...)
echo fail-on-error: report test failures to calling process (0 or 1)

