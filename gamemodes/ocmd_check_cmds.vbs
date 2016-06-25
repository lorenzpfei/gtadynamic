Set fs = CreateObject("Scripting.FileSystemObject")
pfad = fs.GetParentFolderName(Wscript.ScriptFullName)

Set oFile = fs.CreateTextFile(pfad + "\AlleBefehle.txt", True)

Set sDir = fs.getfolder(pfad)
For Each file In sDir.Files
	If (LCase(Right(file.path, 4)) = ".pwn") Then
	
	Set rFile = fs.OpenTextFile(file.path, 1)

	Do While rFile.AtEndOfStream <> True
		
		str = ""
		str = rFile.ReadLine
		
		tmp = InStr(str, "ocmd:")
		if(tmp) Then
			str = Mid(str, tmp+5, InStr(str, "(")-(tmp+5))
			oFile.WriteLine "/"+str
		End If
	Loop
	rFile.Close()
	
    End If
Next

oFile.close()