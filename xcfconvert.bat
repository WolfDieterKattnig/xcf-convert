@echo off
rem ============================================================
rem  xcfconvert.bat - wandelt GIMP-XCF-Dateien in andere Bild-
rem  formate um (GIMP 3 Batch-Modus, korrekte Farben/Ebenen).
rem
rem  Aufruf:
rem    xcfconvert.bat                       alle .xcf im Script-Ordner
rem    xcfconvert.bat C:\Mein\Ordner        alle .xcf im Ordner
rem    xcfconvert.bat C:\Pfad\Logo.xcf      nur diese eine Datei
rem    ... --format=jpg                     Zielformat (png, jpg, webp, ...)
rem    ... --format jpg                     (beide Schreibweisen erlaubt)
rem    xcfconvert.bat --help                diese Hilfe
rem
rem  Einstellungen (GIMP-Pfad, Standardformat) in xcfconvert.ini.
rem ============================================================
setlocal EnableExtensions

set "SCRIPTDIR=%~dp0"
set "INI=%SCRIPTDIR%xcfconvert.ini"
set "PY=%SCRIPTDIR%xcf_convert.py"

rem --- Hilfe ---
if /i "%~1"=="--help" goto help
if /i "%~1"=="-h"     goto help

rem --- Defaults aus der ini-Datei lesen ---
set "GIMP="
set "FORMAT="
if exist "%INI%" (
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%INI%") do (
        if /i "%%a"=="gimp_path" set "GIMP=%%b"
        if /i "%%a"=="format"    set "FORMAT=%%b"
    )
)

rem --- Kommandozeile auswerten ---
rem Hinweis: cmd trennt Argumente auch an '=', deshalb wird
rem sowohl "--format jpg" als auch "--format=jpg" unterstuetzt.
setlocal enabledelayedexpansion
set "SRC="
set "FORMAT="
:args
if "%~1"=="" goto argsdone
set "A=%~1"
if /i "!A:~0,8!"=="--format" (
    if "!A:~8,1!"=="=" (
        set "FORMAT=!A:~9!"
    ) else (
        set "FORMAT=%~2"
        shift
    )
    goto argnext
)
if /i "!A:~0,2!"=="--" goto argnext
set "SRC=%~1"
:argnext
shift
goto args
:argsdone
endlocal & set "SRC=%SRC%" & set "FORMAT=%FORMAT%"

if "%FORMAT%"=="" set "FORMAT=png"

rem --- GIMP-Pfad pruefen ---
if "%GIMP%"=="" set "GIMP=C:\Program Files\GIMP 3\bin\gimp-console-3.exe"
if not exist "%GIMP%" (
    echo FEHLER: GIMP nicht gefunden:
    echo   %GIMP%
    echo Bitte den richtigen Pfad in "%INI%" eintragen ^(Schluessel gimp_path^).
    exit /b 1
)

rem --- Umgebungsvariablen fuer das Python-Script setzen ---
set "XCF_SRC=%SRC%"
set "XCF_FORMAT=%FORMAT%"
set "SRCDIR=%SCRIPTDIR%"

echo Konvertiere XCF -^> %FORMAT% ...
echo.

"%GIMP%" -i -c -n --batch-interpreter=python-fu-eval -b "exec(open(r'%PY%').read())" --quit

echo.
echo Fertig.
exit /b 0

:help
echo.
echo  xcfconvert.bat - XCF-Dateien mit GIMP 3 konvertieren
echo.
echo    xcfconvert.bat                       alle .xcf im Script-Ordner
echo    xcfconvert.bat C:\Mein\Ordner        alle .xcf im angegebenen Ordner
echo    xcfconvert.bat C:\Pfad\Logo.xcf      nur diese eine Datei
echo    ... --format=jpg                     Zielformat, z.B.:
echo    ... --format jpg                     png jpg jpeg tif tiff bmp webp
echo                                         (alles was GIMP exportieren kann)
echo.
echo  Standardformat und GIMP-Pfad stehen in xcfconvert.ini.
echo.
exit /b 0
