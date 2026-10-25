@rem version 2
@echo off
set grp=%1
set sstring=%2
set debug=%~3
if defined debug echo on
set stype=phrase
set chrome="C:\Program Files\Google\Chrome\Application\chrome.exe"
call :main
goto :eof

:main
  set reset=[0m
  set green=[32m
  set blue=[34m
  echo %green%Group to search: %grp%%reset%
  echo %green%Search string: %sstring% %reset%
  set source=source\all-indexes.xml
  set search=tmp\search.xml
  set info2=on
  if not exist %source% echo %red%all-indexes.xml not found in 'source' folder! Can't complete search. Will exit in 20 seconds. & timeout 20 & exit
  set safestring=%sstring:?=_%
  set htmlfile=%cd%\output\%stype%-%grp%-%safestring%.html
  set timeout=60
  if not exist output md output
  if exist %htmlfile% del %htmlfile%
  rem end setup
  call :searchpresent2
  if exist %chrome% (
    echo %blue%start chrome.exe "%htmlfile%"%reset%
    start %chrome% "%htmlfile%"
  ) else (
    echo %blue%start edge.exe "%htmlfile%"%reset%
    start "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "%htmlfile%"
  )
  if '%errorlevel%' == 1 pause
  timeout 60
goto :eof

:searchpresent2
  echo %blue%call xslt3-he -xsl:search-present-target-js.sef.json -s:source/all-indexes.xml -o:%htmlfile% target="%grp%" searchword="%sstring%" %reset%
  call xslt3-he -xsl:search-present-target-js.sef.json -s:source/all-indexes.xml -o:%htmlfile% target="%grp%" searchword="%sstring%"
goto :eof


