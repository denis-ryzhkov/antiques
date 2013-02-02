unit ftbinds;

interface
uses Windows, SysUtils, Dialogs, Registry, Controls;

procedure ftbindDlg(appName,vendorName,defExt,typeID,appFileName,icoFileName:string);
//XMP: ftbindDlg(jr_,'Creosoft','txt','textfile',natfld+jr_+'.exe',natfld+jr_+'.exe,0');

implementation

procedure ftbindDlg(appName,vendorName,defExt,typeID,appFileName,icoFileName:string);
var ext,extdiz:string;
    r:tregistry;
    newext:boolean;
begin
 ext:=defExt;
 if messageDlg('Эта команда позволит Вам связать определённый тип текстового файла с приложением '+vendorName+' '+appName+'. Если Вы будете после этого открывать файл этого типа, то его откроет '+appName+'. Вы согласны?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
  if inputquery('Тип файла','Внимание! '+appName+' внесёт изменения в реестр.',ext) then
   begin
    r:=tRegistry.Create;
    r.RootKey:=HKEY_CLASSES_ROOT;

    r.OpenKey('.'+ext,true);
    extdiz:=r.ReadString('');
    newext:=extdiz='';
    if newext then
     begin
      extdiz:=vendorName+'.'+appName+'.'+typeID;
      r.WriteString('',extdiz);
     end;
    r.CloseKey;

    r.OpenKey(extdiz+'\shell\open\command',true);
    r.WriteString('',appFileName+' "%1"');
    r.CloseKey;

    r.OpenKey(extdiz+'\DefaultIcon',true);
    r.WriteString('',icoFileName);
    r.CloseKey;

    r.Free;
    if newext then
     showmessage(appName+' успешно зарегистрировал новый тип файла "'+ext+'"')
    else
     showmessage(appName+' успешно перерегистрировал тип файла "'+ext+'"');
   end;
end;

end.
