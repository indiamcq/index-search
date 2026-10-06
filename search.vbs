
Dim shell, dbName, objShell, nosp, java, saxon, htmlfile, source, maintab, target, width, height, htpx, wdpx, normhtproportion, normwdproportion, tskgrp, myTitle, curtitle

tskgrp =  Array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
 maintab = Array("main","pics","qbmag","every","files")
 Set objShell = CreateObject("Wscript.Shell")
 nosp = "~"
 java = "javafx\bin\java.exe"
 saxon = "saxon\saxon12he.jar"
 htmlpath = "output\"
 source = "source\all-indexes.xml"
 tabgrp = 4
' Calculate pixels based on screen resolution
width = screen.availWidth
height = screen.availHeight
normhtproportion = 0.5
normwdproportion = 0.28
htpx = height * normhtproportion
wdpx = width * normwdproportion

set myTitle = Document.getElementById("h4")
' Set the size of the window
 window.resizeTo wdpx, htpx
' 1. Create the XML DOM object
'Set xmlDoc = CreateObject("MSXML2.DOMDocument.6.0")
'xmlDoc.setProperty "SelectionLanguage", "XPath"
' 2. Load the XML file
'If xmlDoc.Load("setup.xml") Then
' 	set apptitle = xmlDoc.selectNodes("//setup/apptitle[1]")
'End If
'Set xmlDoc = Nothing
'document.getElementById("apptitle").InnerText = apptitle

Sub window_onload
	IndexSearch.icon = "index.ico"
	call optionShow("search.ini")
	'set curtitle = ReadIni("search.ini", "title","h4")
	'myTitle.InnerText = curtitle
End Sub

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

Sub FindString()
	Dim searchString, selectedValue, selectedOutput, selectedType
	searchString = Replace(document.getElementById("stringSearch").value," ",nosp)
	selectedLet = GetRadioValue(document.myGroup.group)
	selectedValue = ReadIni("search.ini","filter",selectedLet)
	selectedOutput = GetRadioValue(document.outputType.out)
	selectedType = GetRadioValue(document.searchType.type)
	call RunScript("search.cmd",selectedType,searchString,nosp,selectedValue,selectedOutput)
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

Function OpenTab(tabgrp,tabid)
	Dim tab, x, Elem, Elemon, Elemtab , Elemtc, ifrm, tabname, tabactive
	tab = tabgrp
	tabactive = tabid & "tab"
	For x = 0 To Ubound(tabgrp)
	  tabname = tab(x) & "tab"
	  document.getElementById(tab(x)).style.display = "none"
	  document.getElementById(tabname).style.background = "#f1f1f1"
	Next
	document.getElementById(tabid).style.display = "block"
	document.getElementById(tabactive).style.background = "#ccc"
End Function

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

Function optionShow(file)
  dim x, group, grplen, buttonlen, label, text, myRadio, myLabel
  group = "label"
  For x = 0 To Ubound(tskgrp)
    label = tskgrp(x)
	text = ReadIni(file,group,label)
	Set myRadio = Document.getElementById("radio" & label)
	Set myLabel = Document.getElementById("label" & label)
    lbllen = len(text)
    If lbllen > zero Then
		If Not myRadio Is Nothing Then
			myRadio.style.display = "block"
		Else
			MsgBox "Error: Element 'MyRadio' could not be found on the page. radio" & label
		End If
		'myRadio.style.display = "block"
		myLabel.style.display = "block"
		myLabel.InnerText = text
    Else
        myRadio.style.display = "none"
		myLabel.style.display = "none"
    End If
  Next
End Function
