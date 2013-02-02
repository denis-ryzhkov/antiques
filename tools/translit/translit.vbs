'translit.vbs, version 1.0 2008-10-26
'Copyright (c) 2008 Denis Ryzhkov
'http://denis.ryzhkov.org/?soft/translit

If MsgBox( "�� ������� ��� ������ ����������������� ����� ���� ������ � ������� ����� � � ���������?", 1, "translit" ) <> 1 Then: WScript.Quit

Set dict = CreateObject( "Scripting.Dictionary" )
For Each pair in Split( "�=a,�=b,�=v,�=g,�=d,�=e,�=yo,�=zh,�=z,�=i,�=y,�=k,�=l,�=m,�=n,�=o,�=p,�=r,�=s,�=t,�=u,�=f,�=h,�=c,�=ch,�=sh,�=shch,�=y,�=y,�=y,�=e,�=yu,�=ya,�=A,�=B,�=V,�=G,�=D,�=E,�=Yo,�=Zh,�=Z,�=I,�=Y,�=K,�=L,�=M,�=N,�=O,�=P,�=R,�=S,�=T,�=U,�=F,�=H,�=C,�=Ch,�=Sh,�=Shch,�=Y,�=Y,�=Y,�=E,�=Yu,�=Ya", "," )
	dict.Add Left( pair, 1 ), Mid( pair, 3 )
Next

Sub ProcessFile( file )
	oldName = file.name
	newName = ""
	For charInd = 1 To Len( oldName )
		oldChar = Mid( oldName, charInd, 1 )
		newChar = dict.item( oldChar )
		If IsEmpty( newChar ) Then
			newName = newName + oldChar
		Else
			newName = newName + newChar
		End If
	Next
	If newName <> oldName Then ' error if rename to equal
		Do
			On Error Resume Next
	       		file.name = newName
	       		retry = false
	       		If Err.Number <> 0 Then
		       		answer = MsgBox( Err.Description + ": " + file.Path + " -> " + newName, 2, "translit error" ) ' abort-retry-ignore
		       		On Error Goto 0
				If answer = 3 Then: WScript.Quit ' abort
				retry = ( answer = 4 ) ' retry
			End If
		Loop While retry
	End If
End Sub

Sub ProcessFolder( folder )
	For Each file In folder.Files
		ProcessFile file
	Next
	For Each subFolder in folder.subFolders
		ProcessFile subFolder
		ProcessFolder subFolder
	Next
End Sub

Set fso = CreateObject( "Scripting.FileSystemObject" )
ProcessFolder fso.GetFolder( "." )
