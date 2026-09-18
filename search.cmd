@rem version 3
@echo off
set stype=%1
set sstring=%2
set nosp=%3
set grp=%4
set output=%~5
set debug=%~6
call :main
goto :eof

:main
  echo stype=%stype%
  echo sstring=%sstring%
  echo nosp=%nosp%
  echo grp=%grp%
  set source=source\all-indexes.xml
  set search=tmp\search.xml
  set info2=on
  set reset=[0m
  set green=[32m
  set blue=[34m
  if not exist %source% echo %red%all-indexes.xml not found in 'source' folder! Can't complete search. Will exit in 20 seconds. & timeout 20 & exit
  set safestring=%sstring:?=_%
  set htmlfile=%cd%\output\%stype%-%grp%-%safestring%.html
  set java=..\javafx\bin\java.exe
  set saxon=..\saxon\saxon12he.jar
  set timeout=60
  if not exist output md output
  if exist %htmlfile% del %htmlfile%
  rem end setup
  call :searchpresent %stype%
  if exist chrome.exe (
    echo %cyan%start chrome.exe "%outfile%"%reset%
    start chrome.exe "%outfile%"
  ) else (
    echo %cyan%start edge.exe "%outfile%"%reset%
    start "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "%outfile%"
  )
  if '%errorlevel%' == 1 pause
  timeout 60
goto :eof

:searchpresent
  call :xslt search-present-target.xslt %source% %htmlfile% "type=%stype% searchword='%sstring%' nosp=%nosp% target='%grp%' output=%output%"
goto :eof

:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program1: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: External program2: Node-JS   https://nodejs.org/en/
:: Node application: XSLT3 https://www.saxonica.com/download/javascript.xml
:: Required variables: java saxon9
  set script=%~1
  set infile=%~2
  set outfile=%~3
  set params=%~4
  if not exist %infile% echo "infile not found!" & exit /b
  if defined params set params=%params:'="%
  @if defined info2 echo %cyan%%java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%%reset%
  %java% -Xmx1024m  %suppressXsltNamespaceCheck% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  if exist %htmlfile% echo %green%Created: %htmlfile% %reset%
goto :eof
