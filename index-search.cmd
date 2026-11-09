@rem version 5
@echo off
set safeoutfile=%~1
set debug=%~2
if defined debug echo on

call :main
if defined debug pause
goto :eof

:main
  set info2=on
  @set green=[32m
  @set cyan=[36m
  @set blue=[34m
  @set reset=[0m
  echo %green%safeoutfile: %safeoutfile%%reset%
  set source=source\all-indexes.xml
  if not exist %source% echo %red%%source% not found in 'source' folder! Can't complete search. Will exit in 20 seconds. & timeout 20 & exit
  set htmlfile=%cd%\output\%safeoutfile%.html
  echo %htmlfile%
  set java=..\javafx\bin\java.exe
  set saxon=..\saxon\saxon12he.jar
  set timeout=60
  if not exist output md output
  if exist %htmlfile% del %htmlfile%
  rem end setup
  call :searchpresent
  if exist chrome.exe (
    echo %cyan%start chrome.exe "%outfile%"%reset%
    start chrome.exe "%outfile%"
  ) else (
    echo %cyan%start edge.exe "%outfile%"%reset%
    start "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "%outfile%"
  )
  if '%errorlevel%' == 1 pause
  timeout 20
goto :eof

:searchpresent
  @call :xslt index-search.xslt %source% %htmlfile% 
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
