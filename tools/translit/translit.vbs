'translit.vbs, version 1.0 2008-10-26
'Copyright (c) 2008 Denis Ryzhkov
'http://denis.ryzhkov.org/?soft/translit

If MsgBox( "Вы уверены что хотите транслитерировать имена ВСЕХ файлов в текущей папке и её подпапках?", 1, "translit" ) <> 1 Then: WScript.Quit

Set dict = CreateObject( "Scripting.Dictionary" )
For Each pair in Split( "а=a,б=b,в=v,г=g,д=d,е=e,ё=yo,ж=zh,з=z,и=i,й=y,к=k,л=l,м=m,н=n,о=o,п=p,р=r,с=s,т=t,у=u,ф=f,х=h,ц=c,ч=ch,ш=sh,щ=shch,ъ=y,ы=y,ь=y,э=e,ю=yu,я=ya,А=A,Б=B,В=V,Г=G,Д=D,Е=E,Ё=Yo,Ж=Zh,З=Z,И=I,Й=Y,К=K,Л=L,М=M,Н=N,О=O,П=P,Р=R,С=S,Т=T,У=U,Ф=F,Х=H,Ц=C,Ч=Ch,Ш=Sh,Щ=Shch,Ъ=Y,Ы=Y,Ь=Y,Э=E,Ю=Yu,Я=Ya", "," )
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
