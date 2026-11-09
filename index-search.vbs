
Dim shell, dbName, objShell, ini, java, saxon, htmlfile, source, targets, types, formats, width, height, htpx, wdpx, normhtproportion, normwdproportion, tskgrp, myTitle, titleText, curtitle, typeList, formatList, bug1, bug2, bug3, param, cmdfile
'define ini file
ini = "index-search.ini"

'get some file names
param = ReadIni(ini, "files","param")
cmdfile = ReadIni(ini, "files","cmdfile")
icofile = ReadIni(ini, "files","icofile")

'Define some paths'
'java = "javafx\bin\java.exe"
'saxon = "saxon\saxon12he.jar"
'htmlpath = "output\"

'Get array data from ini'
targets = ReadIni(ini, "arrays","targets")
types = ReadIni(ini, "arrays","types")
formats = ReadIni(ini, "arrays","formats")

'Make string into an array
targetList =  Split(targets)
typeList = Split(types)
formatList = Split(formats)

'Create object for starting script'
Set objShell = CreateObject("Wscript.Shell")
'source = "source\all-indexes.xml"

'Define xslt head and tail
xhead = "<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='3.0'>"
xtail = "</xsl:stylesheet>"

' Calculate pixels based on screen resolution
width = screen.availWidth
height = screen.availHeight
normhtproportion = ReadIni(ini, "size","h")
normwdproportion = ReadIni(ini, "size","w")
htpx = height * normhtproportion
wdpx = width * normwdproportion
' Set the size of the window
 window.resizeTo wdpx, htpx

'Get title and subtitle headings
titleText = ReadIni(ini, "title","h4")
choose1 = ReadIni(ini, "title","target")

Sub window_onload
  'IndexSearch.icon = icofile
  set myTitle = Document.getElementById("h4")
  myTitle.innerText = titleText
  call optionShow(ini,targetList,"targets","label")
  call optionShow(ini,typeList,"types","")
  call optionShow(ini,formatList,"formats","")
  'Set bug1 = Document.getElementById("bug1")
  'bug1.innerText = targetList(0)
  'Set bug2 = Document.getElementById("bug2")
  'bug2.innerText = typeList(0)
  'Set bug3 = Document.getElementById("bug3")
  'bug3.innerText = formatList(0)
End Sub

Function optionShow(file,curarray,group,pre)
  dim x, label, text, myLabel, lbllen,TargetNumber
  TargetNumber = 0
  For x = 0 To Ubound(curarray)
    label = curarray(x)
    text = ReadIni(file,group,label)
    Set myLabel = Document.getElementById(pre & label)
    lbllen = len(text)
    If x = TargetNumber Then
      checked = "  checked=''"
    Else
      checked = ""
    End If
    If lbllen > zero Then
      If Not myLabel Is Nothing Then
        myLabel.style.display = "block"
        myLabel.innerHTML = "<input type='radio' name='" & group & "' value='" & label & "'" & checked & "/> " & text
      Else
        MsgBox "Error: Element 'MyLabel' for " & group & " could not be found on the page. radio" & label
      End If
    Else
        myLabel.style.display = "none"
    End If
  Next
End Function

Function GetRadioValue(radioGroup)
  Dim opt
  For Each opt In radioGroup
    If opt.Checked Then
      GetRadioValue = opt.Value
      Exit Function
    End If
  Next
  GetRadioValue = ""
End Function

' Get form information
Sub FindString()
Dim searchString, selectedValue, selectedOutput, selectedType
'Make safe string from searchString
searchString = document.getElementById("stringSearch").value
searchStringSafe = Replace(searchString,"[","_")
searchStringSafe = Replace(searchStringSafe,"]","_")
searchStringSafe = Replace(searchStringSafe,"(","_")
searchStringSafe = Replace(searchStringSafe,")","_")
searchStringSafe = Replace(searchStringSafe,"|","_")
searchStringSafe = Replace(searchStringSafe," ","~")
'get values from form
selectedLet = GetRadioValue(document.myTarget.targets)
selectedFilter = ReadIni(ini,"filters",selectedLet)
selectedFormat = GetRadioValue(document.formatType.formats)
selectedType = GetRadioValue(document.searchType.types)
outFileSafe = selectedType & "-" & selectedFilter & "-" & selectedFormat & "_" & searchStringSafe
'write -index-param.xslt
stype = "<xsl:param name='type'>" + selectedType + "</xsl:param>"
searchwords = "<xsl:param name='searchwords'>" + searchString + "</xsl:param>"
starget = "<xsl:param name='target'>" + selectedFilter + "</xsl:param>"
sformat = "<xsl:param name='format'>" + selectedFormat + "</xsl:param>"
xmlString = xhead + stype + searchwords + starget + sformat + xtail
Set xmlDoc = CreateObject("Msxml2.DOMDocument.3.0")
xmlDoc.LoadXML xmlString
xmlDoc.Save param
'sent up param for cmd file
call RunScript(cmdfile,outFileSafe,"","","","")
'call RunJavaApp(selectedType,selectedFormat,searchStringSafe)
End Sub

Sub RunScript(script,var1,var2,var3,var4,var5)
  'writeProjIni projIni,"variables",styleout
  dim infopar(5), x
  infopar(0) = chr(34) & script & chr(34)
  infopar(1) = " " & var1
  infopar(2) = " " & var2
  infopar(3) = " " & var3
  infopar(4) = " " & var4
  infopar(5) = " " & var5
  cmdline = infopar(0) & infopar(1) & infopar(2) & infopar(3) & infopar(4) & infopar(5)
  objShell.run(cmdline)
End Sub


' read any ini file
Function ReadIni( myFilePath, mySection, myKey )
  ' This function returns a value read from an INI file
  ' Arguments:
  ' myFilePath  [string]  the (path and) file name of the INI file
  ' mySection   [string]  the section in the INI file to be searched
  ' myKey       [string]  the key whose value is to be returned
  ' Returns:
  ' the [string] value for the specified key in the specified section
  ' CAVEAT:     Will return a space if key exists but value is blank
  ' Written by Keith Lacelle
  ' Modified by Denis St-Pierre and Rob van der Woude
  Const ForReading   = 1
  Const ForWriting   = 2
  Const ForAppending = 8
  Dim intEqualPos
  Dim objFSO, objIniFile
  Dim strFilePath, strKey, strLeftString, strLine, strSection
  Set objFSO = CreateObject( "Scripting.FileSystemObject" )
  ReadIni     = ""
  strFilePath = Trim( myFilePath )
  strSection  = Trim( mySection )
  strKey      = Trim( myKey )
  If objFSO.FileExists( strFilePath ) Then
      Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
      Do While objIniFile.AtEndOfStream = False
          strLine = Trim( objIniFile.ReadLine )
          ' Check if section is found in the current line
          If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
              strLine = Trim( objIniFile.ReadLine )
              ' Parse lines until the next section is reached
              Do While Left( strLine, 1 ) <> "["
                  ' Find position of equal sign in the line
                  intEqualPos = InStr( 1, strLine, "=", 1 )
                  If intEqualPos > 0 Then
                      strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                      ' Check if item is found in the current line
                      If LCase( strLeftString ) = LCase( strKey ) Then
                          ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                          ' In case the item exists but value is blank
                          If ReadIni = "" Then
                               ReadIni = " "
                          End If
                          ' Abort loop when item is found
                          Exit Do
                      End If
                  End If
                  ' Abort if the end of the INI file is reached
                  If objIniFile.AtEndOfStream Then Exit Do
                  ' Continue with next line
                  strLine = Trim( objIniFile.ReadLine )
              Loop
          Exit Do
          End If
      Loop
      objIniFile.Close
  Else
      Msgbox strFilePath & " doesn't exists. Exiting..."
  End If
End Function

'Sub RunJavaApp(type,format,safeString)
'  Dim objShell, outFile
'  Set objShell = CreateObject("Shell.Application")
'  outFile = type + "-" + format + "-" + safeString + ".xslt"
'  ' Option 1: Run a Java JAR file
'  objShell.ShellExecute java, "-jar " & saxon & "-o:" & outFile & " all-index.xml search-present-target.xslt", "", "open", 1
'  Set objShell = Nothing
'End Sub


