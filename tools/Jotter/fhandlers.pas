unit fhandlers;

interface
uses Windows, SysUtils, iniFiles, Dialogs, shellApi;

type tFHandler=
 class
   inif:tIniFile;
   constructor Create(inifile:tIniFile);
   procedure handle(fn:string);
   procedure handlewith(fn:string);
   destructor Destroy;override;
 end;

implementation

const
 fhandler_='FHandler';

constructor tFHandler.Create(inifile:tIniFile);
begin
 inherited create;
 inif:=inifile;
end;

procedure tFHandler.handle(fn:string);
var ext,fhfn,path:string;

procedure doHandle;
begin
 path:=extractfilepath(fn);
 if fhfn=':' then
  shellExecute(0,'open',pchar(fn),'',pchar(path),sw_Show)
 else
  if fileexists(fhfn) then
   shellExecute(0,'open',pchar(fhfn),pchar(fn),pchar(path),sw_Show)
  else
   showmessage('Обработчик "'+fhfn+'" не найден'); 
end;

begin
 ext:=extractfileext(fn);
 fhfn:=inif.ReadString(fhandler_,ext,'');
 if (fhfn='') or ((fhfn<>':') and (not fileexists(fhfn))) then
  if inputquery('Имя файла обработчика','или пустую строку для автообработки',fhfn) then
   begin
    if fhfn='' then
     fhfn:=':';
    inif.WriteString(fhandler_,ext,fhfn);
    doHandle;
   end
  else
 else
  doHandle;
end;

procedure tFHandler.handlewith(fn:string);
begin
 inif.WriteString(fhandler_,extractfileext(fn),'');
 handle(fn);
end;

destructor tFHandler.Destroy;
begin
 inherited destroy;
end;

end.
