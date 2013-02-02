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
 if messageDlg('��� ������� �������� ��� ������� ����������� ��� ���������� ����� � ����������� '+vendorName+' '+appName+'. ���� �� ������ ����� ����� ��������� ���� ����� ����, �� ��� ������� '+appName+'. �� ��������?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
  if inputquery('��� �����','��������! '+appName+' ����� ��������� � ������.',ext) then
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
     showmessage(appName+' ������� ��������������� ����� ��� ����� "'+ext+'"')
    else
     showmessage(appName+' ������� ����������������� ��� ����� "'+ext+'"');
   end;
end;

end.
